// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause

// Package mak contains code to help make things.
package mak

import (
	"reflect"
	"testing"
)

type M map[string]int

func TestSet(t *testing.T) {
	t.Run("unnamed", func(t *testing.T) {
		var m map[string]int
		Set(&m, "foo", 42)
		Set(&m, "bar", 1)
		Set(&m, "bar", 2)
		want := map[string]int{
			"foo": 42,
			"bar": 2,
		}
		if got := m; !reflect.DeepEqual(got, want) {
			t.Errorf("got %v; want %v", got, want)
		}
	})
	t.Run("named", func(t *testing.T) {
		var m M
		Set(&m, "foo", 1)
		Set(&m, "bar", 1)
		Set(&m, "bar", 2)
		want := M{
			"foo": 1,
			"bar": 2,
		}
		if got := m; !reflect.DeepEqual(got, want) {
			t.Errorf("got %v; want %v", got, want)
		}
	})
}

func TestNonNil(t *testing.T) {
	var s []string
	NonNil(&s)
	if len(s) != 0 {
		t.Errorf("slice len = %d; want 0", len(s))
	}
	if s == nil {
		t.Error("slice still nil")
	}

	s = append(s, "foo")
	NonNil(&s)
	if len(s) != 1 {
		t.Errorf("len = %d; want 1", len(s))
	}
	if s[0] != "foo" {
		t.Errorf("value = %q; want foo", s)
	}

	var m map[string]string
	NonNil(&m)
	if len(m) != 0 {
		t.Errorf("map len = %d; want 0", len(s))
	}
	if m == nil {
		t.Error("map still nil")
	}
}

func TestNonNilMapForJSON(t *testing.T) {
	type M map[string]int
	var m M
	NonNilMapForJSON(&m)
	if m == nil {
		t.Fatal("still nil")
	}
}

func TestNonNilSliceForJSON(t *testing.T) {
	type S []int
	var s S
	NonNilSliceForJSON(&s)
	if s == nil {
		t.Fatal("still nil")
	}
}
