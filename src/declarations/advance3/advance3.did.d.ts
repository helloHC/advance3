import type { Principal } from '@dfinity/principal';
export type AssocList = [] | [[[Key, Proposal], List_1]];
export type AssocList_1 = [] | [[[Key_1, null], List_2]];
export interface Branch { 'left' : Trie, 'size' : bigint, 'right' : Trie }
export interface Branch_1 { 'left' : Trie_1, 'size' : bigint, 'right' : Trie_1 }
export type Hash = number;
export interface Key { 'key' : bigint, 'hash' : Hash }
export interface Key_1 { 'key' : Principal, 'hash' : Hash }
export interface Leaf { 'size' : bigint, 'keyvals' : AssocList }
export interface Leaf_1 { 'size' : bigint, 'keyvals' : AssocList_1 }
export type List = [] | [[Principal, List]];
export type List_1 = [] | [[[Key, Proposal], List_1]];
export type List_2 = [] | [[[Key_1, null], List_2]];
export type Operations = { 'stop' : null } |
  { 'addRestriction' : null } |
  { 'delete' : null } |
  { 'removeRestriction' : null } |
  { 'create' : null } |
  { 'start' : null } |
  { 'install' : null };
export interface Proposal {
  'isApprover' : boolean,
  'wasmCode' : [] | [number],
  'done' : boolean,
  'refusers' : List,
  'operation' : Operations,
  'proposer' : Principal,
  'approvers' : List,
  'canisterID' : [] | [Principal],
}
export type Set = { 'branch' : Branch_1 } |
  { 'leaf' : Leaf_1 } |
  { 'empty' : null };
export type Trie = { 'branch' : Branch } |
  { 'leaf' : Leaf } |
  { 'empty' : null };
export type Trie_1 = { 'branch' : Branch_1 } |
  { 'leaf' : Leaf_1 } |
  { 'empty' : null };
export interface Wallet_center {
  'getAllCanister' : () => Promise<Set>,
  'getFoundation' : () => Promise<Set>,
  'getProposals' : () => Promise<Trie>,
  'propose' : (
      arg_0: Operations,
      arg_1: [] | [Principal],
      arg_2: [] | [number],
    ) => Promise<undefined>,
  'vote' : (arg_0: bigint, arg_1: boolean) => Promise<undefined>,
}
export interface _SERVICE extends Wallet_center {}
