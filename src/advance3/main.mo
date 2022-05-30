import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import TrieSet "mo:base/TrieSet";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import List "mo:base/List";
import Cycles "mo:base/ExperimentalCycles";

import IC "./ic";

import Types "./types";

actor class Wallet_center (_threshold: Nat, _total: Nat, members: [Principal]) = self {
    stable var foundationSet : TrieSet.Set<Principal> = TrieSet.fromArray<Principal>(members, Principal.hash, Principal.equal);
    stable var canisterSet : TrieSet.Set<Principal> = TrieSet.empty<Principal>();
    stable var canisterRestrictionSet : TrieSet.Set<Principal> = TrieSet.empty<Principal>();
    stable var proposals : Trie.Trie<Nat, Types.Proposal> = Trie.empty<Nat, Types.Proposal>();
    stable var proposalsID : Nat = 0;
    stable var threshold : Nat = _threshold;
    stable var total : Nat = _total;

    func isMember(user: Principal) : Bool {
        TrieSet.mem(foundationSet, user, Principal.hash(user), Principal.equal)
    };

    func hasCanister(wrap: TrieSet.Set<Principal>, canister: ?Principal) : Bool {
        switch(canister) {
            case(?canister) {
                return TrieSet.mem(wrap, canister, Principal.hash(canister), Principal.equal);
            };
            case(null) {
                return false;
            };
        };
    };

    func hasApprover(num: Nat) : Bool {
        if(num >= threshold) {
            true
        } else {
            false
        }
    };

    func hasDone(approveCount: Nat, refuseCount: Nat) : Bool {
        assert(total > refuseCount and total > approveCount);
        if(approveCount >= threshold or approveCount + refuseCount == total or total - refuseCount < threshold) {
            true
        } else {
            false
        }
    };

    //添加提案
    public shared ({ caller }) func propose(operation: Types.Operations, canisterID: ?Principal, wasmCode: ?Nat8) : async () {
        assert(isMember(caller));

        switch(operation) {
            case(#addRestriction) {
                assert(not hasCanister(canisterRestrictionSet, canisterID));
                pushPropose(caller, operation, canisterID, wasmCode);
            };
            case(#removeRestriction) {
                assert(hasCanister(canisterRestrictionSet, canisterID));
                pushPropose(caller, operation, canisterID, wasmCode);
            };
            case(#create) {
                pushPropose(caller, operation, canisterID, wasmCode);
            };
            case(_) {
                if(hasCanister(canisterRestrictionSet, canisterID)) {
                    pushPropose(caller, operation, canisterID, wasmCode);
                } else {
                    let ic : IC.Self = actor("aaaa-aa");
                    switch(operation) {
                        case (#install) {
                            await ic.install_code({
                                arg = [];
                                wasm_module = [Option.unwrap(wasmCode)];
                                mode = #install;
                                canister_id = Option.unwrap(canisterID);
                            });
                        };
                        case (#start) {
                            await ic.start_canister({
                                canister_id = Option.unwrap(canisterID);
                            });
                        };
                        case (#stop) {
                            await ic.stop_canister({
                                canister_id = Option.unwrap(canisterID);
                            });
                        };
                        case (#delete) {
                            await ic.delete_canister({
                                canister_id = Option.unwrap(canisterID);
                            });
                        };
                        case(_) {};
                    };
                }
            };
        };
    };

    func pushPropose(caller: Principal, operation: Types.Operations, _canisterID: ?Principal, _wasmCode: ?Nat8) {
        proposalsID += 1;
        proposals := Trie.put(proposals, { hash = Hash.hash(proposalsID); key = proposalsID}, Nat.equal, {
            proposer = caller;
            wasmCode = _wasmCode;
            operation = operation;
            canisterID = _canisterID;
            approvers = List.nil<Principal>();
            refusers = List.nil<Principal>();
            isApprover = false;
            done = false;
        }).0;
    };

    //表决提案
    public shared ({ caller }) func vote(proposalsID: Nat, isApprove: Bool) : async () {
        switch (Trie.get(proposals, { hash = Hash.hash(proposalsID); key = proposalsID }, Nat.equal)) {
            case(?_proposal) {
                var _approvers : List.List<Principal> = List.nil();
                var _refusers : List.List<Principal> = List.nil();
                if(isApprove) {
                    _approvers := List.push(caller, _proposal.approvers);
                    _refusers := _proposal.refusers;
                } else {
                    _approvers := _proposal.approvers;
                    _refusers := List.push(caller, _proposal.refusers);
                };
                let suggestion = {
                    proposer = _proposal.proposer;
                    wasmCode = _proposal.wasmCode;
                    operation = _proposal.operation;
                    canisterID = _proposal.canisterID;
                    approvers = _approvers;
                    refusers = _refusers;
                    isApprover = hasApprover(List.size(_approvers));
                    done = hasDone(List.size(_approvers), List.size(_refusers));
                };
                proposals := Trie.replace(proposals, { hash = Hash.hash(proposalsID); key = proposalsID }, Nat.equal, ?suggestion).0;
                if(hasApprover(List.size(_approvers))) {
                    await operate(suggestion);
                }
            };
            case(_) {
                
            };
        };
    };

    //执行提案
    func operate(proposal: Types.Proposal) : async () {
        let ic : IC.Self = actor("aaaa-aa");
        switch(proposal.operation) {
            case (#create) {
                Cycles.add(1_000_000_000_000);
                let canister_settings = {
                    freezing_threshold = null;
                    controllers = ?[Principal.fromActor(self)];
                    memory_allocation = null;
                    compute_allocation = null;
                };
                let result = await ic.create_canister({ settings = ?canister_settings });
                canisterSet := TrieSet.put(canisterSet, result.canister_id, Principal.hash(result.canister_id), Principal.equal);
            };
            case (#install) {
                await ic.install_code({
                    arg = [];
                    wasm_module = [Option.unwrap(proposal.wasmCode)];
                    mode = #install;
                    canister_id = Option.unwrap(proposal.canisterID);
                });
            };
            case (#start) {
                await ic.start_canister({
                    canister_id = Option.unwrap(proposal.canisterID);
                });
            };
            case (#stop) {
                await ic.stop_canister({
                    canister_id = Option.unwrap(proposal.canisterID);
                });
            };
            case (#delete) {
                await ic.delete_canister({
                    canister_id = Option.unwrap(proposal.canisterID);
                });
            };
            case (#addRestriction) {
                canisterRestrictionSet := TrieSet.put(canisterRestrictionSet, Option.unwrap(proposal.canisterID), Principal.hash(Option.unwrap(proposal.canisterID)), Principal.equal);
            };
            case (#removeRestriction) {
                canisterRestrictionSet := TrieSet.delete(canisterRestrictionSet, Option.unwrap(proposal.canisterID), Principal.hash(Option.unwrap(proposal.canisterID)), Principal.equal);
            };
        };
    };

    public query func getProposals () : async Trie.Trie<Nat, Types.Proposal> {
        proposals
    };

    public query func getFoundation () : async TrieSet.Set<Principal> {
        foundationSet
    };
    
    public query func getAllCanister () : async TrieSet.Set<Principal> {
        canisterSet
    };
};