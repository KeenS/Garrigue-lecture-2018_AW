(* 2 �ˑ��a *)
(* ���� (��) �͋A�[�^�̓���ȗ�ł���D*)

Print ex.
(* Inductive ex (A : Type) (P : A -> Prop) : Prop :=
   ex_intro : forall x : A, P x -> ex P.    *)

(*
ex (fun x:A => P(x)) �� exists x:A, P(x) �Ə����Ă������D 

���̒�`������ƁCex P = ��x, P(x) �� x �� P(x) �̑΂ł����Ȃ��D�΂̑� 2 �v�f�ɑ� 1 �v�f��
����Ă���̂ŁC���̐ς��u�ˑ��a�v�Ƃ����D�i���X�ˑ��̂���֐��^���`���Y���Ƃ����ˑ�
�ςƌ��Ȃ��Ȃ�C������� A ��Y���Ƃ��钼�a�W���ɂȂ�j
���Ɍ��Ă���悤�ɁC�ؖ��̒��ňˑ��a���\�z���鎞�ɁCexists �Ƃ��������g���D
*)

Require Import Arith.

Print le.
(* Inductive le (n : nat) : nat -> Prop :=
   le_n : n <= n | le_S : forall m : nat, n <= m -> n <= S m.  *)

Lemma exists_pred : forall x, x > 0 -> exists y, x = S y.
Proof.
  intros x Hx.
  destruct Hx.
  exists 0. reflexivity.
  exists m. reflexivity.
Qed.

(* ��L�� ex �� Prop �ɏZ�ނ��̂Ȃ̂ŁC�_�����̒��ł����g���Ȃ��D�������C�v���O�����̒��ňˑ��a���g��������������D���̎��ɂ� sig ���g���D*)
Print sig.
(* Inductive sig (A : Type) (P : A -> Prop) : Type :=
   exist : forall x : A, P x -> sig P.   *)

(*
sig (fun x:T => Px) �� {x:T | Px} �Ƃ������Dex �Ɠ��l�ɁC��̓I�Ȓl�� exists �Ŏw�肷��D
�������������t���Ȓl���������S�Ȋ֐���������D
*)

(*
Definition safe_pred x : x > 0 -> {y | x = S y}.
intros x Hx.
destruct Hx.
Error: Case analysis on sort Set is not allowed for inductive definition le.
*)

(* �l����낤�Ƃ��Ă��鎞�CProp �̏ؖ��ɑ΂���ꍇ�������s���Ȃ��D���ʂ̒l�ɑ΂���ꍇ�������s��Ȃ���΂Ȃ�Ȃ��D *)

Definition safe_pred x : x > 0 -> {y | x = S y}.
  intros Hx.
  destruct x as [|x'].
  elim (le_Sn_O 0). (* ���̏ꍇ���s�v�ł��邱�Ƃ̏ؖ� *)
  exact Hx.
  exists x'.
  reflexivity. (* �����̏ؖ� *)
Defined. (* ��`�𓧖��ɂ��C�v�Z�Ɏg����悤�ɂ��� *)

(* �ؖ����ꂽ�֐��� OCaml �̊֐��Ƃ��ėA�o�ł���D���̏ꍇ�CProp �̕������������. *)

Require Extraction.
Extraction safe_pred.
(** val safe_pred : nat -> nat **)
(*let safe_pred = function
  | O -> assert false (* absurd case *)
  | S x�f -> x�f  *)


(* ����̈ˑ��a *)

(* �ʏ�̐^�U�l�ɑ΂��āC�����ꍇ�ɏ�����t����ˑ��a����`����Ă���D*)
Print sumbool.
(* Inductive sumbool (A B : Prop) : Set :=
   left : A -> {A} + {B} | right : B -> {A} + {B}.  *)

(* ��ɂ�����悤�ɁCsumbool A B �� {A}+{B} �Ə�����D
  ������g���ƁC�����𔻒肷��悤�Ȋ֐��̌^���ȒP�ɏ�����D *)

Check le_lt_dec.
(* : forall n m : nat, {n <= m} + {m < n} *)


(* 3 ����̏ؖ� *)

Require Import List.

Section Sort.

Variables (A:Set)(le:A->A->Prop).
Variable le_refl: forall x, le x x.
Variable le_trans: forall x y z, le x y -> le y z -> le x z.
Variable le_total: forall x y, {le x y}+{le y x}.

Inductive le_list x : list A -> Prop :=
| le_nil : le_list x nil
| le_cons : forall y l, le x y -> le_list x l -> le_list x (y::l).
Inductive sorted : list A -> Prop :=
| sorted_nil : sorted nil
| sorted_cons : forall a l, le_list a l -> sorted l -> sorted (a::l).

Hint Constructors le_list sorted.

Fixpoint insert a (l: list A) :=
match l with
| nil => (a :: nil)
| b :: l' => if le_total a b then a :: l else b :: insert a l'
end.
Fixpoint isort (l : list A) : list A :=
match l with
| nil => nil
| a :: l' => insert a (isort l')
end.

Lemma le_list_insert : forall a b l,
le a b -> le_list a l -> le_list a (insert b l).
Proof.
  intros.
  induction H0.
  simpl. info_auto.
  simpl.
  destruct (le_total b y). (* le_total �̌��ʂ̏ꍇ���� *)
  auto.
  auto.
Qed.

Lemma le_list_trans : forall a b l,
le a b -> le_list b l -> le_list a l.
Proof.
  intros.
  induction H0. constructor.
  info_eauto using le_trans. (* le_trans ���q���g�ɉ����Ď����ؖ� *)
Qed.

Parameter insert_ok : forall a l, sorted l -> sorted (insert a l).
Parameter isort_ok : forall l, sorted (isort l).

Inductive Permutation : list A -> list A -> Prop :=
| perm_nil: Permutation nil nil (* ���X�g�̑g�ݑւ� *)
| perm_skip: forall x l l',
Permutation l l' -> Permutation (x::l) (x::l')
| perm_swap: forall x y l, Permutation (y::x::l) (x::y::l)
| perm_trans: forall l l' l'',
Permutation l l' -> Permutation l' l'' -> Permutation l l''.

Parameter Permutation_refl : forall l, Permutation l l.
Parameter insert_perm : forall l a, Permutation (a :: l) (insert a l).
Parameter isort_perm : forall l, Permutation l (isort l).

Definition safe_isort : forall l, {l'|sorted l' /\ Permutation l l'}.
  intros. exists (isort l).
  split. apply isort_ok. apply isort_perm.
Defined.

End Sort.

Check safe_isort.

Definition le_total : forall m n, {m <= n} + {n <= m}.
  intros. destruct (le_lt_dec m n). auto. auto with arith.
Defined.

Definition isort_le := safe_isort nat le le_total.
(* �S�Ă��ؖ�����ƁCle_refl �� le_trans ���K�v�ɂȂ� *)
Eval compute in proj1_sig (isort_le (3 :: 1 :: 2 :: 0 :: nil)).
 (* = 0 :: 1 :: 2 :: 3 :: nil  *)

Extraction "isort.ml" isort_le. (* �R�[�h���t�@�C�� isort.ml �ɏ������� *)

(* ���K��� 3.1 Parameter �� Theorem �ɕς��C�ؖ�������������. *)
