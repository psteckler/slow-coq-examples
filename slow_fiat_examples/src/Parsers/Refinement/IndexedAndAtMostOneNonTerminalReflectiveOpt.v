(** First step of a splitter refinement; indexed representation, and handle all rules with at most one nonterminal; leave a reflective goal *)
Require Import Coq.Strings.String.
Require Import Fiat.Common.List.ListFacts.
Require Import Fiat.ADTNotation.BuildADT Fiat.ADTNotation.BuildADTSig.
Require Import Fiat.ADT.ComputationalADT.
Require Import Fiat.ADTRefinement.
Require Import Fiat.ADTRefinement.BuildADTRefinements.HoneRepresentation.
Require Import Fiat.ADTRefinement.GeneralBuildADTRefinements.
Require Import Fiat.Parsers.ParserADTSpecification.
Require Import Fiat.Parsers.Refinement.IndexedAndAtMostOneNonTerminalReflective.
Require Import Fiat.Parsers.StringLike.Core.
Require Import Fiat.Parsers.BaseTypes.
Require Import Fiat.Parsers.Splitters.RDPList.
Require Import Fiat.Parsers.ContextFreeGrammar.Carriers.
Require Import Fiat.Parsers.ContextFreeGrammar.PreNotations.
Require Import Fiat.Common.
Require Import Fiat.Common.List.ListFacts.

Local Open Scope string_scope.

(* TODO: find a better place for this *)
Instance match_item_Proper {Char A}
  : Proper (eq ==> pointwise_relation _ eq ==> pointwise_relation _ eq ==> eq)
           (fun (it : Core.item Char) T NT
            => match it return A with
               | Core.Terminal t => T t
               | Core.NonTerminal nt => NT nt
               end).
Proof.
  intros []; repeat intro; subst; auto.
Qed.

Instance option_rect_Proper {A P}
  : Proper (pointwise_relation _ eq ==> eq ==> eq ==> eq)
           (@option_rect A (fun _ => P)).
Proof.
  intros ?????? []; repeat intro; subst; simpl; auto.
Qed.

Module opt2.
  Definition id {A} := Eval compute in @id A.
  Definition fold_right {A B} := Eval compute in @List.fold_right A B.
  Definition uniquize_sig {A} : { v : _ | v = @Operations.List.uniquize A }.
  Proof.
    eexists.
    cbv [Operations.List.uniquize Equality.list_bin orb].
    change @List.fold_right with @fold_right.
    reflexivity.
  Defined.
  Definition uniquize {A} := Eval cbv [proj1_sig uniquize_sig] in proj1_sig (@uniquize_sig A).
  Definition ret_cases_BoolDecR := Eval compute in ret_cases_BoolDecR.
End opt2.

Module opt.
  Definition map {A B} := Eval compute in @List.map A B.
  Definition flat_map {A B} := Eval compute in @List.flat_map A B.
  Definition up_to := Eval compute in @Operations.List.up_to.
  Definition length {A} := Eval compute in @List.length A.
  Definition nth {A} := Eval compute in @List.nth A.
  Definition id {A} := Eval compute in @id A.
  Definition combine {A B} := Eval compute in @List.combine A B.
  Definition string_beq := Eval compute in Equality.string_beq.
  Definition first_index_default {A} := Eval compute in @Operations.List.first_index_default A.
  Definition list_bin_eq := Eval compute in list_bin_eq.
  Definition filter_out_eq := Eval compute in filter_out_eq.
  Definition find {A} := Eval compute in @List.find A.
  Definition leb := Eval compute in Compare_dec.leb.
  Definition minus := Eval compute in minus.
  Definition drop {A} := Eval compute in @Operations.List.drop A.
  Definition andb := Eval compute in andb.
  Definition nat_rect {A} := Eval compute in @nat_rect A.
  Definition option_rect {A} := Eval compute in @option_rect A.
  Definition has_only_terminals {Char} := Eval compute in @has_only_terminals Char.
  Definition sumbool_of_bool := Eval compute in Sumbool.sumbool_of_bool.
  Definition length_of_any_productions' {Char} := Eval compute in @FixedLengthLemmas.length_of_any_productions' Char.
  Definition collapse_length_result := Eval compute in FixedLengthLemmas.collapse_length_result.
  Definition expanded_fallback_list'_body_sig {G} : { b : _ | b = @expanded_fallback_list'_body G }.
  Proof.
    eexists.
    cbv [expanded_fallback_list'_body to_production_opt production_carrier_valid production_carrierT rdp_list_predata default_production_carrierT default_nonterminal_carrierT rdp_list_production_carrier_valid default_production_carrier_valid Lookup_idx FixedLengthLemmas.length_of_any FixedLengthLemmas.length_of_any_nt FixedLengthLemmas.length_of_any_nt' nonterminals_listT rdp_list_nonterminals_listT nonterminals_length initial_nonterminals_data rdp_list_initial_nonterminals_data FixedLengthLemmas.length_of_any_nt_step is_valid_nonterminal of_nonterminal remove_nonterminal ContextFreeGrammar.Core.Lookup rdp_list_of_nonterminal grammar_of_pregrammar rdp_list_remove_nonterminal Lookup_string list_to_productions rdp_list_is_valid_nonterminal If_Then_Else].
    change @fst with @opt.fst.
    change @snd with @opt.snd.
    change @List.map with @map.
    change @List.length with @length.
    change Equality.string_beq with string_beq.
    change @Operations.List.first_index_default with @first_index_default.
    change RDPList.list_bin_eq with list_bin_eq.
    change RDPList.filter_out_eq with filter_out_eq.
    change @Operations.List.up_to with @up_to.
    change @List.find with @find.
    change @List.nth with @nth.
    change Compare_dec.leb with leb.
    change Datatypes.andb with andb.
    change (?x - ?y) with (minus x y).
    change @Operations.List.drop with @drop.
    change @Datatypes.nat_rect with @nat_rect.
    change @Datatypes.option_rect with @option_rect.
    change @Sumbool.sumbool_of_bool with sumbool_of_bool.
    change @FixedLengthLemmas.length_of_any_productions' with @length_of_any_productions'.
    change @FixedLengthLemmas.collapse_length_result with collapse_length_result.
    change @IndexedAndAtMostOneNonTerminalReflective.has_only_terminals with @has_only_terminals.
    reflexivity.
  Defined.
  Definition expanded_fallback_list'_body (ps : list (String.string * Core.productions Ascii.ascii)) : default_production_carrierT -> ret_cases.
  Proof.
    let term := constr:(fun H : NoDupR _ _ => proj1_sig (@expanded_fallback_list'_body_sig {| pregrammar_productions := ps |})) in
    let term := (eval cbv [proj1_sig expanded_fallback_list'_body_sig pregrammar_productions] in term) in
    let term := match term with
                  | (fun _ => ?term) => term
                end in
    exact term.
  Defined.
  Definition ret_cases_to_comp_sig {HSLM G} : { r : _ | r = @ret_cases_to_comp HSLM G }.
  Proof.
    eexists.
    cbv [ret_cases_to_comp to_production rdp_list_predata rdp_list_to_production default_to_production Lookup_idx].
    change @Operations.List.drop with @drop.
    change @snd with @opt.snd.
    change @fst with @opt.fst.
    change @List.nth with @nth.
    change (?x - ?y) with (minus x y).
    change @List.length with @length.
    change @List.map with @map.
    reflexivity.
  Defined.
  Definition ret_cases_to_comp {HSLM G}
    := Eval cbv [proj1_sig ret_cases_to_comp_sig] in proj1_sig (@ret_cases_to_comp_sig HSLM G).
End opt.

Class opt_of {T} (term : T) := mk_opt_of : T.
(*Class do_idtac {T} (x : T) := dummy_idtac : True.
Local Hint Extern 0 (do_idtac ?msg) => idtac "<infomsg>" msg "</infomsg>"; exact I : typeclass_instances.
Local Ltac cidtac term := constr:(_ : do_idtac term).
Local Ltac opt_of_context term :=
  match (eval cbv beta iota zeta in term) with
  | appcontext G[map snd (opt.id ?ls)]
    => let G' := context G[opt.id (opt.map opt.snd ls)] in
       opt_of_context G'
  | appcontext G[List.length (opt.id ?ls)]
    => let G' := context G[opt.id (opt.length ls)] in
       opt_of_context G'
  | appcontext G[minus (opt.id ?x) (opt.id ?y)]
    => let G' := context G[opt.id (opt.minus x y)] in
       opt_of_context G'
  | appcontext G[Operations.List.up_to (opt.id ?n)]
    => let G' := context G[opt.id (opt.up_to n)] in
       opt_of_context G'
  | appcontext G[S (opt.id ?n)]
    => let G' := context G[opt.id (S n)] in
       opt_of_context G'
  | appcontext G[ret (opt.id ?n)]
    => let G' := context G[opt.id (ret n)] in
       opt_of_context G'
  | appcontext G[pair (opt.id ?x) (opt.id ?y)]
    => let G' := context G[opt.id (pair x y)] in
       opt_of_context G'
  | appcontext G[cons (opt.id ?x) (opt.id ?y)]
    => let G' := context G[opt.id (cons x y)] in
       opt_of_context G'
  | appcontext G[Operations.List.uniquize (opt.id ?beq) (opt.id ?ls)]
    => let G' := context G[opt.id (opt.uniquize beq ls)] in
       opt_of_context G'
  | appcontext G[nth (opt.id ?n) (opt.id ?ls) (opt.id ?d)]
    => let G' := context G[opt.id (opt.nth n ls d)] in
       opt_of_context G'
  | appcontext G[List.combine (opt.id ?a) (opt.id ?b)]
    => let G' := context G[opt.id (opt.combine a b)] in
       opt_of_context G'
  | appcontext G[map (opt.id ?f) (opt.id ?ls)]
    => let G' := context G[opt.id (opt.map f ls)] in
       let G' := (eval cbv beta in G') in
       opt_of_context G'
  | appcontext G[flat_map (opt.id ?f) (opt.id ?ls)]
    => let G' := context G[opt.id (opt.flat_map f ls)] in
       let G' := (eval cbv beta in G') in
       opt_of_context G'
  | appcontext G[opt.flat_map (opt.id ?f) ?ls]
    => let G' := context G[opt.flat_map f ls] in
       opt_of_context G'
  | appcontext G[opt.map (opt.id ?f) ?ls]
    => let G' := context G[opt.map f ls] in
       opt_of_context G'
  | appcontext G[fun x => opt.id (@?f x)]
    => let G' := context G[opt.id f] in
       opt_of_context G'
  | appcontext G[flat_map ?f (opt.id ?ls)]
    => let f' := constr:(fun x => _ : opt_of (f (opt.id x))) in
       let G' := context G[opt.id (opt.flat_map f' ls)] in
       let G' := (eval cbv beta in G') in
       opt_of_context G'
  | appcontext G[map ?f (opt.id ?ls)]
    => let f' := constr:(fun x => _ : opt_of (f (opt.id x))) in
       let G' := context G[opt.id (opt.map f' ls)] in
       let G' := (eval cbv beta in G') in
       opt_of_context G'
  | appcontext G[fold_right ?f (opt.id ?d) (opt.id ?ls)]
    => let f' := constr:(fun x => _ : opt_of (f (opt.id x))) in
       let G' := context G[opt.id (opt.fold_right f' d ls)] in
       let G' := (eval cbv beta in G') in
       opt_of_context G'
  | ?term' => term'
  end.*)
Class constr_eq {A} {B} (x : A) (y : B) := make_constr_eq : True.
Local Hint Extern 0 (constr_eq ?x ?y) => constr_eq x y; exact I : typeclass_instances.
Local Ltac opt_of term :=
  let retv :=
      lazymatch (eval cbv beta iota zeta in term) with
      | List.map snd (opt.id ?ls)
        => constr:(opt.id (opt.map opt.snd ls))
      | List.length (opt.id ?ls)
        => constr:(opt.id (opt.length ls))
      | minus (opt.id ?x) (opt.id ?y)
        => constr:(opt.id (opt.minus x y))
      | Operations.List.up_to (opt.id ?n)
        => constr:(opt.id (opt.up_to n))
      | @fst ?A ?B (opt.id ?n)
        => constr:(opt.id (@opt.fst A B n))
      | @snd ?A ?B (opt.id ?n)
        => constr:(opt.id (@opt.snd A B n))
      | S (opt.id ?n)
        => constr:(opt.id (S n))
      | Core.ret (opt.id ?n)
        => constr:(opt.id (Core.ret n))
      | pair (opt.id ?x) (opt.id ?y)
        => constr:(opt.id (pair x y))
      | cons (opt.id ?x) (opt.id ?y)
        => constr:(opt.id (cons x y))
      | Operations.List.uniquize (opt2.id ?beq) (opt.id ?ls)
        => constr:(opt2.id (opt2.uniquize beq ls))
      | Operations.List.uniquize (opt.id ?beq) (opt.id ?ls)
        => constr:(opt2.id (opt2.uniquize beq ls))
      | List.nth (opt.id ?n) (opt.id ?ls) (opt.id ?d)
        => constr:(opt.id (opt.nth n ls d))
      | List.combine (opt.id ?a) (opt.id ?b)
        => constr:(opt.id (opt.combine a b))
      | List.map (fun x : ?T => opt.id ?f) (opt.id ?ls)
        => constr:(opt.id (opt.map (fun x : T => f) ls))
      | List.map (opt.id ?f) (opt.id ?ls)
        => constr:(opt.id (opt.map f ls))
      | List.flat_map (opt.id ?f) (opt.id ?ls)
        => constr:(opt.id (opt.flat_map f ls))
      | opt.flat_map (opt.id ?f) ?ls
        => constr:(opt.flat_map f ls)
      | opt.map (opt.id ?f) ?ls
        => constr:(opt.map f ls)
      | fun x => opt.id (@?f x)
        => constr:(opt.id f)
      | List.flat_map ?f (opt.id ?ls)
        => let f' := constr:(fun x => _ : opt_of (f (opt.id x))) in
           let G' := constr:(opt.id (opt.flat_map f' ls)) in
           (eval cbv beta in G')
      | @List.map ?A ?B ?f (opt.id ?ls)
        => let f' := constr:(fun x => _ : opt_of (f (opt.id x))) in
           let G' := constr:(opt.id (@opt.map A B f' ls)) in
           let G' := (eval cbv beta in G') in
           G'
      | List.fold_right orb false (opt.id ?ls)
        => constr:(opt2.fold_right orb false ls)
      | List.fold_right orb false (opt2.id ?ls)
        => constr:(opt2.fold_right orb false ls)
      | List.fold_right ?f (opt.id ?d) (opt.id ?ls)
        => let f' := constr:(fun x => _ : opt_of (f (opt2.id x))) in
           let G' := constr:(opt2.id (opt2.fold_right f' d ls)) in
           (eval cbv beta in G')
      | List.fold_right ?f (opt.id ?d) (opt2.id ?ls)
        => let f' := constr:(fun x => _ : opt_of (f (opt2.id x))) in
           let G' := constr:(opt2.id (opt2.fold_right f' d ls)) in
           (eval cbv beta in G')
      | opt.id ?f ?x
        => constr:(opt.id (f x))
      | opt2.id ?f ?x
        => constr:(opt2.id (f x))
      | ?f (opt.id ?x)
        => let f' := opt_of f in
           let term' := (eval cbv beta iota zeta in (f' (opt.id x))) in
           match constr:Set with
           | _
             => let dummy := constr:(_ : constr_eq term' (f (opt.id x))) in
                term'
           | _
             => opt_of term'
           end
      | ?f (opt2.id ?x)
        => let f' := opt_of f in
           let term' := (eval cbv beta iota zeta in (f' (opt2.id x))) in
           match constr:Set with
           | _
             => let dummy := constr:(_ : constr_eq term' (f (opt2.id x))) in
                term'
           | _
             => opt_of term'
           end
      | ?f ?x => let f' := opt_of f in
                 let x' := opt_of x in
                 let term' := (eval cbv beta iota zeta in (f' x')) in
                 lazymatch x' with
                 | opt.id ?x''
                   => opt_of term'
                 | _ => term'
                 end(*
                 match term' with
                 | f x => term'
                 | ?term'' => opt_of term''
                 end*)
      | (fun x : ?T => ?f)
        => (eval cbv beta iota zeta in (fun x : T => _ : opt_of f))
      | if ?b then ?x else ?y
        => let b' := opt_of b in
           let x' := opt_of x in
           let y' := opt_of y in
           constr:(if b' then x' else y')
      | ?term'
        => term'
      end in
  (*let term' := (eval cbv beta iota zeta in term) in
  let dummy := match constr:Set with
               | _ => let dummy := constr:(_ : constr_eq retv term') in constr:Set
               | _ => cidtac retv
               end in*)
  retv.
Local Hint Extern 0 (opt_of ?term) => (let x := opt_of term in exact x) : typeclass_instances.

Section IndexedImpl_opt.
  Context {HSLM : StringLikeMin Ascii.ascii} {HSL : StringLike Ascii.ascii} {HSI : StringIso Ascii.ascii}
          {HSLP : StringLikeProperties Ascii.ascii} {HSIP : StringIsoProperties Ascii.ascii}
          {HSEP : StringEqProperties Ascii.ascii}.
  Context (G : pregrammar Ascii.ascii).

  Let predata := @rdp_list_predata _ G.
  Local Existing Instance predata.

  Definition opt_rindexed_spec_sig : { a : ADT (string_rep Ascii.ascii String default_production_carrierT) | a = rindexed_spec G }.
  Proof.
    eexists.
    cbv [rindexed_spec rindexed_spec' default_production_carrierT default_nonterminal_carrierT expanded_fallback_list' forall_reachable_productions_if_eq].
    simpl @production_carrierT.
    cbv [default_production_carrierT default_nonterminal_carrierT].
    change (@expanded_fallback_list'_body G) with (opt.id (@opt.expanded_fallback_list'_body G)).
    change (pregrammar_productions G) with (opt.id (pregrammar_productions G)).
    change ret_cases_BoolDecR with (opt2.id opt2.ret_cases_BoolDecR).
    change (@nil ?A) with (opt.id (@nil A)).
    change (0::opt.id nil)%list with (opt.id (0::nil)%list).
    unfold opt.expanded_fallback_list'_body.
    do 2 (idtac;
          let G := match goal with |- ?G => G end in
          let G' := opt_of G in
          change G').
    unfold ret_cases_to_comp.
    reflexivity.
  Defined.

  Definition opt_rindexed_spec'
    := Eval cbv [proj1_sig opt_rindexed_spec_sig] in proj1_sig opt_rindexed_spec_sig.
  Lemma opt_rindexed_spec'_correct
  : opt_rindexed_spec' = rindexed_spec G.
  Proof.
    exact (proj2_sig opt_rindexed_spec_sig).
  Qed.

  Lemma FirstStep'
  : refineADT (string_spec G HSL) opt_rindexed_spec'.
  Proof.
    rewrite opt_rindexed_spec'_correct.
    apply FirstStep_preopt.
  Qed.

  Local Arguments opt.leb !_ !_.
  Local Arguments opt.minus !_ !_.

  Definition FirstStep_sig
  : { sp : _ & refineADT (string_spec G HSL) sp }.
  Proof.
    eexists.
    eapply transitivityT; [ apply FirstStep' | ].
    unfold opt_rindexed_spec'.
    hone method "splits".
    {
      setoid_rewrite refineEquiv_pick_eq'.
      simplify with monad laws.
      simpl; subst_body; subst.
      eapply refine_under_bind_both; [ | solve [ intros; higher_order_reflexivity ] ].
      match goal with
      | [ |- ?R ?x ?y ]
        => cut (x = y);
             [ let H := fresh in
               generalize y;
               let y' := fresh in
               intros y' H; subst y'; reflexivity
             | ]
      end.
      unfold opt.id, opt2.id.
      repeat match goal with
             | [ |- opt.length (opt.nth ?n ?ls nil) = _ ]
               => etransitivity;
                    [ symmetry;
                      eexact (List.map_nth opt.length ls nil n
                              : opt.nth _ (opt.map _ _) 0 = opt.length (opt.nth _ _ _))
                    | ]
             | [ |- opt.map (fun x : ?T => opt.minus (opt.length (opt.snd x)) ?v) (pregrammar_productions G) = _ ]
               => transitivity (opt.map (fun x => opt.minus x v) (opt.map opt.length (opt.map opt.snd (pregrammar_productions G))));
                    [ change @opt.map with @List.map;
                      rewrite !List.map_map;
                      reflexivity
                    | reflexivity ]
             | [ |- context[opt.length (opt.map ?f ?ls)] ]
               => replace (opt.length (opt.map f ls)) with (opt.length ls)
                 by (change @opt.length with @List.length;
                     change @opt.map with @List.map;
                     rewrite List.map_length;
                     reflexivity)
             | [ |- context[opt.length (opt.up_to ?n)] ]
               => replace (opt.length (opt.up_to n)) with n
                 by (change @opt.length with @List.length;
                     change @opt.up_to with @Operations.List.up_to;
                     rewrite length_up_to; reflexivity)
             | [ |- opt.map opt.length (opt.nth ?n ?ls nil) = _ ]
               => etransitivity;
                    [ symmetry;
                      eexact (List.map_nth (opt.map opt.length) ls nil n
                              : opt.nth _ (opt.map _ _) nil = opt.map opt.length (opt.nth _ _ _))
                    | ]
             (*| [ |- opt.id _ = _ ] => apply f_equal*)
             | [ |- ret _ = _ ] => apply f_equal
             | [ |- fst _ = _ ] => apply f_equal
             | [ |- snd _ = _ ] => apply f_equal
             | [ |- opt.fst _ = _ ] => apply f_equal
             | [ |- opt.snd _ = _ ] => apply f_equal
             | [ |- S _ = _ ] => apply f_equal
             | [ |- opt.collapse_length_result _ = _ ] => apply f_equal
             | [ |- ret_length_less _ = _ ] => apply f_equal
             | [ |- ret_nat _ = _ ] => apply f_equal
             | [ |- ret_nat _ = _ ] => eapply (f_equal ret_nat)
             | [ |- ret_pick _ = _ ] => eapply (f_equal ret_pick)
             | [ |- opt.has_only_terminals _ = _ ] => apply f_equal
             | [ |- opt.up_to _ = _ ] => apply f_equal
             | [ |- cons _ _ = _ ] => apply f_equal2
             | [ |- pair _ _ = _ ] => apply f_equal2
             | [ |- cons _ _ = _ ] => eapply (f_equal2 cons)
             | [ |- pair _ _ = _ ] => eapply (f_equal2 pair)
             | [ |- orb _ _ = _ ] => apply f_equal2
             | [ |- andb _ _ = _ ] => apply f_equal2
             | [ |- opt.andb _ _ = _ ] => apply f_equal2
             | [ |- opt.drop _ _ = _ ] => apply f_equal2
             | [ |- opt.leb _ _ = _ ] => apply f_equal2
             | [ |- opt.minus _ _ = _ ] => apply f_equal2
             | [ |- opt.combine _ _ = _ ] => apply f_equal2
             | [ |- opt2.ret_cases_BoolDecR _ _ = _ ] => apply f_equal2
             | [ |- EqNat.beq_nat _ _ = _ ] => apply f_equal2
             | [ |- opt.nth _ _ _ = _ ] => apply f_equal3
             | [ |- 0 = _ ] => reflexivity
             | [ |- opt.length (pregrammar_productions G) = _ ] => reflexivity
             | [ |- opt.length ?x = _ ] => is_var x; reflexivity
             | [ |- opt.map opt.length ?x = _ ] => is_var x; reflexivity
             | [ |- nil = _ ] => reflexivity
             | [ |- false = _ ] => reflexivity
             | [ |- ret_dummy = _ ] => reflexivity
             | [ |- invalid = _ ] => reflexivity
             | [ |- ?x = _ ] => is_var x; reflexivity
             | [ |- opt.map opt.snd (pregrammar_productions G) = _ ] => reflexivity
             | [ |- opt.map opt.length (opt.map opt.snd (pregrammar_productions G)) = _ ] => reflexivity
             | [ |- opt2.uniquize opt2.ret_cases_BoolDecR _ = _ ] => apply f_equal
             | [ |- (If _ Then _ Else _) = _ ] => apply (f_equal3 If_Then_Else)
             | [ |- (match _ with true => _ | false => _ end) = _ ]
               => apply (f_equal3 (fun (b : bool) A B => if b then A else B))
             | [ |- match ?v with nil => _ | cons x xs => _ end = _ :> ?P ]
               => let T := type of v in
                  let v' := fresh in
                  evar (v' : T);
                  let A := match (eval hnf in T) with list ?A => A end in
                  refine (@ListMorphisms.list_caset_Proper' A P _ _ _ _ _ _ _ _ _
                          : _ = match v' with nil => _ | cons x xs => _ end);
                  subst v';
                  [ | intros ?? | ]
             | [ |- @opt2.fold_right ?A ?B _ _ _ = _ ]
               => refine (((_ : Proper (pointwise_relation _ _ ==> _ ==> _ ==> eq) (@List.fold_right A B)) : Proper _ (@opt2.fold_right A B)) _ _ _ _ _ _ _ _ _);
                    [ intros ?? | | ]
             | [ |- @opt.map ?A ?B ?f ?v = _ ]
               => not constr_eq v (pregrammar_productions G);
                    let f' := head f in
                    not constr_eq f' (@opt.length);
                    refine (((_ : Proper (pointwise_relation _ _ ==> _ ==> eq) (@List.map A B)) : Proper _ (@opt.map A B)) _ _ _ _ _ _);
                    [ intro | ]
             | [ |- @opt.flat_map ?A ?B _ ?v = _ ]
               => not constr_eq v (pregrammar_productions G);
                    refine (((_ : Proper (pointwise_relation _ _ ==> _ ==> eq) (@List.flat_map A B)) : Proper _ (@opt.flat_map A B)) _ _ _ _ _ _);
                    [ intro | ]
             | [ |- match ?v with Core.Terminal t => _ | Core.NonTerminal nt => _ end = _ :> ?P ]
               => apply match_item_Proper; [ | intro | intro ]
             | [ |- opt.option_rect _ _ _ _ = _ ]
               => eapply (option_rect_Proper : Proper _ (opt.option_rect _));
                    [ intro | | ]
             | _ => progress cbv beta
             end.
      reflexivity.
      reflexivity.
      reflexivity.
    }
    cbv beta.
    apply reflexivityT.
  Defined.

  Definition opt_rindexed_spec
    := Eval cbv [projT1 FirstStep_sig] in projT1 FirstStep_sig.

  Lemma FirstStep
    : refineADT (string_spec G HSL) opt_rindexed_spec.
  Proof.
    apply (projT2 FirstStep_sig).
  Qed.
End IndexedImpl_opt.

Declare Reduction opt_red_FirstStep := cbv [opt_rindexed_spec opt.map opt.flat_map opt.up_to opt.length opt.nth opt.id opt.combine opt.expanded_fallback_list'_body opt.minus opt.drop opt.string_beq opt.first_index_default opt.list_bin_eq opt.filter_out_eq opt.find opt.leb opt.andb opt.nat_rect opt.option_rect opt.has_only_terminals opt.sumbool_of_bool opt.length_of_any_productions' opt.collapse_length_result opt.fst opt.snd].

Ltac opt_red_FirstStep :=
  cbv [opt_rindexed_spec opt.map opt.flat_map opt.up_to opt.length opt.nth opt.id opt.combine opt.expanded_fallback_list'_body opt.minus opt.drop opt.string_beq opt.first_index_default opt.list_bin_eq opt.filter_out_eq opt.find opt.leb opt.andb opt.nat_rect opt.option_rect opt.has_only_terminals opt.sumbool_of_bool opt.length_of_any_productions' opt.collapse_length_result opt.fst opt.snd].
