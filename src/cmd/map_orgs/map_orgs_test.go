package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	pcre "github.com/gijsbers/go-pcre"
)

func TestMapOrganizationColdAndWarmCache(t *testing.T) {
	oldREMap, oldUseDB := gREMap, gUseDB
	t.Cleanup(func() {
		gREMap, gUseDB = oldREMap, oldUseDB
	})
	gUseDB = false

	for _, tc := range []struct {
		name    string
		pattern string
		company string
		want    string
	}{
		{"exact", "^example$", "Example", "Example Inc."},
		{"mysql escaping", `^example\\.?[[:space:]]+inc\\.?$`, "Example Inc.", "Example Inc."},
		{"no match", "^other$", "Example", ""},
	} {
		t.Run(tc.name, func(t *testing.T) {
			gREMap = map[string]*pcre.Regexp{}
			mappings := &allMappings{Mappings: [][2]string{{tc.pattern, "Example Inc."}}}
			for _, phase := range []string{"cold", "warm"} {
				cache := map[string]string{}
				missing := map[string]int{}
				got := mapOrganization(nil, tc.company, strings.ToLower(tc.company), mappings, cache, missing, map[string]struct{}{}, 1)
				if got != tc.want {
					t.Errorf("%s cache: got %q, want %q", phase, got, tc.want)
				}

				if tc.want != "" && missing[tc.company] != 0 {
					t.Errorf("%s cache: matched organization recorded as missing", phase)
				}
			}
		})
	}
}

func TestMapOrgsWrapperWithoutDatabase(t *testing.T) {
	dir := t.TempDir()
	script, err := os.ReadFile("../../map_orgs.sh")
	if err != nil {
		t.Fatal(err)
	}
	for name, contents := range map[string][]byte{
		"map_orgs.sh": script,
		"mysql":       []byte("#!/bin/sh\necho unexpected-database-access >&2\nexit 1\n"),
		"map_orgs":    []byte("#!/bin/sh\n[ \"$NO_ACQS\" = 1 ] || exit 1\n[ -z \"$USE_DB\" ] || exit 1\n"),
	} {
		if err := os.WriteFile(filepath.Join(dir, name), contents, 0755); err != nil {
			t.Fatal(err)
		}
	}
	cmd := exec.Command("bash", "map_orgs.sh")
	cmd.Dir = dir
	cmd.Env = append(os.Environ(), "PATH="+dir+string(os.PathListSeparator)+os.Getenv("PATH"), "USE_DB=", "SH_DSN=")
	output, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("wrapper failed: %v\n%s", err, output)
	}
	if strings.Contains(string(output), "unexpected-database-access") {
		t.Fatalf("wrapper tried to access MySQL without USE_DB:\n%s", output)
	}
}
