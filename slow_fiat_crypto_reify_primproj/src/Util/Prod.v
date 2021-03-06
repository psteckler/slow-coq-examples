(** * Classification of the [×] Type *)
(** In this file, we classify the basic structure of [×] types ([prod]
    in Coq).  In particular, we classify equalities of non-dependent
    pairs (inhabitants of [×] types), so that when we have an equality
    between two such pairs, or when we want such an equality, we have
    a systematic way of reducing such equalities to equalities at
    simpler types. *)
Require Import Crypto.Util.Equality.
Require Export Crypto.Util.GlobalSettings.
Require Export Crypto.Util.FixCoqMistakes.

Local Arguments fst {_ _} _.
Local Arguments snd {_ _} _.
Local Arguments f_equal {_ _} _ {_ _} _.

(*Scheme Equality for Datatypes.prod.*)

Definition prod_beq (A B : Type) (eq_A : A -> A -> bool) (eq_B : B -> B -> bool) (X Y : A * B) : bool
  := (eq_A (fst X) (fst Y) && eq_B (snd X) (snd Y))%bool.

Lemma internal_prod_dec_bl
      (A B : Type) (eq_A : A -> A -> bool) (eq_B : B -> B -> bool) (A_bl : forall x y : A, eq_A x y = true -> x = y)
      (B_bl : forall x y : B, eq_B x y = true -> x = y) (x y : A * B)
  : prod_beq A B eq_A eq_B x y = true -> x = y.
Proof.
  unfold prod_beq.
  specialize (A_bl (fst x) (fst y)).
  specialize (B_bl (snd x) (snd y)).
  edestruct eq_A, eq_B; simpl; try reflexivity; try discriminate.
  destruct x, y; simpl in *; destruct A_bl, B_bl; reflexivity.
Defined.

Lemma internal_prod_dec_lb
      (A B : Type) (eq_A : A -> A -> bool) (eq_B : B -> B -> bool) (A_lb : forall x y : A, x = y -> eq_A x y = true)
      (B_lb : forall x y : B, x = y -> eq_B x y = true) (x y : A * B)
  : x = y -> prod_beq A B eq_A eq_B x y = true.
Proof.
  unfold prod_beq.
  intro; subst y.
  rewrite A_lb, B_lb by reflexivity; reflexivity.
Defined.

Definition prod_eq_dec
           (A B : Type) (eq_A : A -> A -> bool) (eq_B : B -> B -> bool) (A_bl : forall x y : A, eq_A x y = true -> x = y)
           (B_bl : forall x y : B, eq_B x y = true -> x = y) (A_lb : forall x y : A, x = y -> eq_A x y = true)
           (B_lb : forall x y : B, x = y -> eq_B x y = true) (x y : A * B)
  : { x = y } + { x <> y }.
Proof.
  destruct (prod_beq A B eq_A eq_B x y) eqn:H; [ left | right ].
  { eauto using internal_prod_dec_bl. }
  { intro; subst y.
    rewrite internal_prod_dec_lb in H by auto.
    discriminate. }
Defined.

Definition surjective_pairing : forall {A B : Type} (p : A * B), p = (fst p, snd p)
  := fun _ _ _ => eq_refl.

(** ** Equality for [prod] *)
Section prod.
  (** *** Projecting an equality of a pair to equality of the first components *)
  Definition fst_path {A B} {u v : prod A B} (p : u = v)
  : fst u = fst v
    := f_equal fst p.

  (** *** Projecting an equality of a pair to equality of the second components *)
  Definition snd_path {A B} {u v : prod A B} (p : u = v)
  : snd u = snd v
    := f_equal snd p.

  (** *** Equality of [prod] is itself a [prod] *)
  Definition path_prod_uncurried {A B : Type} (u v : prod A B)
             (pq : prod (fst u = fst v) (snd u = snd v))
    : u = v.
  Proof.
    destruct u as [u1 u2], v as [v1 v2]; simpl in *.
    destruct pq as [p q].
    destruct p, q; simpl in *.
    reflexivity.
  Defined.

  (** *** Curried version of proving equality of sigma types *)
  Definition path_prod {A B : Type} (u v : prod A B)
             (p : fst u = fst v) (q : snd u = snd v)
    : u = v
    := path_prod_uncurried u v (pair p q).

  (** *** Equivalence of equality of [prod] with a [prod] of equality *)
  (** We could actually use [IsIso] here, but for simplicity, we
      don't.  If we wanted to deal with proofs of equality of × types
      in dependent positions, we'd need it. *)
  Definition path_prod_uncurried_iff {A B}
             (u v : @prod A B)
    : u = v <-> (prod (fst u = fst v) (snd u = snd v)).
  Proof.
    split; [ intro; subst; split; reflexivity | apply path_prod_uncurried ].
  Defined.

  (** *** Eta-expansion of [@eq (prod _ _)] *)
  Definition path_prod_eta {A B} {u v : @prod A B} (p : u = v)
    : p = path_prod_uncurried u v (fst_path p, snd_path p).
  Proof. destruct u, p; reflexivity. Defined.

  (** *** Induction principle for [@eq (prod _ _)] *)
  Definition path_prod_rect {A B} {u v : @prod A B} (P : u = v -> Type)
             (f : forall p q, P (path_prod_uncurried u v (p, q)))
    : forall p, P p.
  Proof. intro p; specialize (f (fst_path p) (snd_path p)); destruct u, p; exact f. Defined.
  Definition path_prod_rec {A B u v} (P : u = v :> @prod A B -> Set) := path_prod_rect P.
  Definition path_prod_ind {A B u v} (P : u = v :> @prod A B -> Prop) := path_prod_rec P.
End prod.

(** ** Useful Tactics *)
(** *** [inversion_prod] *)
Ltac simpl_proj_pair_in H :=
  repeat match type of H with
         | context G[fst (pair ?x ?p)]
           => let G' := context G[x] in change G' in H
         | context G[snd (pair ?x ?p)]
           => let G' := context G[p] in change G' in H
         end.
Ltac induction_path_prod H :=
  let H0 := fresh H in
  let H1 := fresh H in
  induction H as [H0 H1] using path_prod_rect;
  simpl_proj_pair_in H0;
  simpl_proj_pair_in H1.
Ltac inversion_prod_step :=
  match goal with
  | [ H : _ = pair _ _ |- _ ]
    => induction_path_prod H
  | [ H : pair _ _ = _ |- _ ]
    => induction_path_prod H
  end.
Ltac inversion_prod := repeat inversion_prod_step.

(** This turns a goal like [x = let v := p in let '(x, y) := f v in x
    + y)] into a goal like [x = fst (f p) + snd (f p)].  Note that it
    inlines [let ... in ...] as well as destructuring lets. *)
Ltac only_eta_expand_and_contract :=
  repeat match goal with
         | [ |- context[let '(x, y) := ?e in _] ]
           => rewrite (surjective_pairing e)
         | _ => rewrite <- !surjective_pairing
         end.
Ltac eta_expand :=
  repeat match goal with
         | _ => progress cbv beta iota zeta
         | [ |- context[let '(x, y) := ?e in _] ]
           => rewrite (surjective_pairing e)
         | _ => rewrite <- !surjective_pairing
         end.
