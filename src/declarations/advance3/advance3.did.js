export const idlFactory = ({ IDL }) => {
  const Branch_1 = IDL.Rec();
  const List = IDL.Rec();
  const List_1 = IDL.Rec();
  const List_2 = IDL.Rec();
  const Trie = IDL.Rec();
  const Hash = IDL.Nat32;
  const Key_1 = IDL.Record({ 'key' : IDL.Principal, 'hash' : Hash });
  List_2.fill(IDL.Opt(IDL.Tuple(IDL.Tuple(Key_1, IDL.Null), List_2)));
  const AssocList_1 = IDL.Opt(IDL.Tuple(IDL.Tuple(Key_1, IDL.Null), List_2));
  const Leaf_1 = IDL.Record({ 'size' : IDL.Nat, 'keyvals' : AssocList_1 });
  const Trie_1 = IDL.Variant({
    'branch' : Branch_1,
    'leaf' : Leaf_1,
    'empty' : IDL.Null,
  });
  Branch_1.fill(
    IDL.Record({ 'left' : Trie_1, 'size' : IDL.Nat, 'right' : Trie_1 })
  );
  const Set = IDL.Variant({
    'branch' : Branch_1,
    'leaf' : Leaf_1,
    'empty' : IDL.Null,
  });
  const Branch = IDL.Record({
    'left' : Trie,
    'size' : IDL.Nat,
    'right' : Trie,
  });
  const Key = IDL.Record({ 'key' : IDL.Nat, 'hash' : Hash });
  List.fill(IDL.Opt(IDL.Tuple(IDL.Principal, List)));
  const Operations = IDL.Variant({
    'stop' : IDL.Null,
    'addRestriction' : IDL.Null,
    'delete' : IDL.Null,
    'removeRestriction' : IDL.Null,
    'create' : IDL.Null,
    'start' : IDL.Null,
    'install' : IDL.Null,
  });
  const Proposal = IDL.Record({
    'isApprover' : IDL.Bool,
    'wasmCode' : IDL.Opt(IDL.Nat8),
    'done' : IDL.Bool,
    'refusers' : List,
    'operation' : Operations,
    'proposer' : IDL.Principal,
    'approvers' : List,
    'canisterID' : IDL.Opt(IDL.Principal),
  });
  List_1.fill(IDL.Opt(IDL.Tuple(IDL.Tuple(Key, Proposal), List_1)));
  const AssocList = IDL.Opt(IDL.Tuple(IDL.Tuple(Key, Proposal), List_1));
  const Leaf = IDL.Record({ 'size' : IDL.Nat, 'keyvals' : AssocList });
  Trie.fill(
    IDL.Variant({ 'branch' : Branch, 'leaf' : Leaf, 'empty' : IDL.Null })
  );
  const Wallet_center = IDL.Service({
    'getAllCanister' : IDL.Func([], [Set], ['query']),
    'getFoundation' : IDL.Func([], [Set], ['query']),
    'getProposals' : IDL.Func([], [Trie], ['query']),
    'propose' : IDL.Func(
        [Operations, IDL.Opt(IDL.Principal), IDL.Opt(IDL.Nat8)],
        [],
        [],
      ),
    'vote' : IDL.Func([IDL.Nat, IDL.Bool], [], []),
  });
  return Wallet_center;
};
export const init = ({ IDL }) => {
  return [IDL.Nat, IDL.Nat, IDL.Vec(IDL.Principal)];
};
