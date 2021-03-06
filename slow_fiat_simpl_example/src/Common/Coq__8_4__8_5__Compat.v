Ltac shelve_unifiable := idtac.
Ltac shelve := idtac.

(** [set (x := y)] is about 50x slower than it needs to be in Coq 8.4,
    but is about 4x faster than the alternatives in 8.5.  See
    https://coq.inria.fr/bugs/show_bug.cgi?id=3280 (comment 13) for
    more details. *)
Ltac fast_set' x y :=
  pose y as x;
  first [ progress change y with x
        | progress repeat match goal with
                          | [ |- appcontext G[?e] ]
                            => constr_eq y e;
                               let G' := context G[x] in
                               change G'
                          end ].
Tactic Notation "fast_set" "(" ident(x) ":=" constr(y) ")" := fast_set' x y.
