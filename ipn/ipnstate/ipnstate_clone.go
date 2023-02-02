// Copyright (c) Tailscale Inc & AUTHORS
// SPDX-License-Identifier: BSD-3-Clause

// Code generated by tailscale.com/cmd/cloner; DO NOT EDIT.

package ipnstate

import (
	"net/netip"

	"tailscale.com/tailcfg"
)

// Clone makes a deep copy of TKAFilteredPeer.
// The result aliases no memory with the original.
func (src *TKAFilteredPeer) Clone() *TKAFilteredPeer {
	if src == nil {
		return nil
	}
	dst := new(TKAFilteredPeer)
	*dst = *src
	dst.TailscaleIPs = append(src.TailscaleIPs[:0:0], src.TailscaleIPs...)
	return dst
}

// A compilation failure here means this code must be regenerated, with the command at the top of this file.
var _TKAFilteredPeerCloneNeedsRegeneration = TKAFilteredPeer(struct {
	Name         string
	ID           tailcfg.NodeID
	StableID     tailcfg.StableNodeID
	TailscaleIPs []netip.Addr
}{})
