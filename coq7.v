
(* 2 �����̂��߂̍�� *)
(* auto with arith *)
(*�O�񌩂� auto �������R���ɑ΂��Ďg���Ƃ��Carith �Ƃ����藝�̃f�[�^�x�[�X���g��Ȃ���΂Ȃ�Ȃ��D*)
Require Import Arith.
Goal forall m n, m + n = n + m.
auto with arith.
Qed.

(*
ring
auto with arith �͒藝�����ԂɓK�p���邾���Ȃ̂ŁC���������G�ɂȂ�Ɖ����Ȃ����Ƃ������D�������ɕϊ��ł��鎞�ɂ́Cring ���g���Ή�����D*)
Require Import Ring.


Goal forall m n p, m * n + p = p + n * m.
intros.
auto with arith. (* �����N���Ȃ� *)
ring.
Qed.

(*
omega
�s�����Ɋւ��āComega ���ƂĂ��֗��ł���D�s�������ؖ����邾���łȂ��C����̒��̖����������Ă����D*)
Require Import Omega.
Goal forall m n, m <= n -> m < n + 1.
intros. omega.
Qed.
Goal forall m n, m < n -> n < m -> False.
intros. omega.
Qed.

(* 3 �ő���񐔂̌v�Z *)

Require Import Arith Euclid Ring Omega.

Check modulo.
(* : forall n : nat, n > 0 ->
   forall m : nat, {r : nat | exists q : nat, m = q * n + r /\ n > r}  *)

(*
������ 0 �łȂ��Ƃ�������������C���ʂ͈ˑ��^�ɂȂ��Ă���D�v���O�����Ŏg���ɂ́C�܂������̏��������Ȃ���΂Ȃ�Ȃ��D�����Ɍ�Ҋ֐� S �������邱�Ƃŏ�������������D�����̏��Ԃ����ʂɖ߂��D*)

Definition mod' n m := modulo (S m) (lt_O_Sn m) n.

(* ����� gcd ����`�ł���͂��D���ʂ͈ˑ��ςȂ̂ŁCproj1 sig �Œ��g�����o���΂����D*)

(*
Fixpoint gcd (m n : nat) {struct m} : nat :=
match m with
| 0 => n
| S m�f => gcd (proj1_sig (mod�f n m�f)) m
end.

Error:
Recursive definition of gcd is ill-formed.
Recursive call to gcd has principal argument equal to
"proj1_sig (mod�f n m�f)" instead of "m�f".

�ǂ����CCoq �� n mod m�f �� m�f ��菬�������Ƃ𗝉����Ă��Ȃ��悤���D�����@�͂Q����D
�_�~�[�̈��� ��� m ���傫���_�~�[�̈�����ǉ����āC���̈����ɑ΂���A�[�@���g���D
Fixpoint gcd (h:nat) m n {struct h} :=
match m with
| 0 => n
| S m�f =>
match h with
| 0 => 1
| S h�f => gcd h�f (proj1_sig (mod�f n m�f)) m
end
end.
h �Ɋւ���ꍇ��������ɐ�������ih �� 0 �ɂȂ邱�Ƃ͂Ȃ��j���Ƃ��ؖ����Ȃ���΂Ȃ�Ȃ����C����͂Ȃ��D�������C���̂������g���ƁCExtraction �̌�ł� h ���R�[�h�̒��Ɏc��C�{���̃A���S���Y���Ə�������Ă��܂��D

���b�A�[�@ ���b�ȏ����Ƃ́C�����Ȍ�����������Ȃ������̂��Ƃ������D���R���̏�ł� < �͐��b�ł���D����̈������S�Ă̍ċA�Ăяo���Ő��b�ȏ����ɂ����Č������Ă���Ȃ�΁C�֐��̌v�Z�������ɑ������Ƃ͂Ȃ��̂ŁCCoq ����`��F�߂�D�i���ۂɂ͌����̏ؖ��̍\���Ɋւ���\���I�A�[�@���g���Ă���j

Fixpoint �̑���� Function ���g���Cstruct�i�\���j�� wf�i���b�j�ɕς���D���̕��@��
�́C��`�Ɠ����Ɉ������������Ȃ邱�Ƃ��ؖ����Ȃ���΂Ȃ�Ȃ��D
 *)

Require Import Recdef.
Function gcd (m n : nat) {wf lt m} : nat :=
match m with
| 0 => n
| S m' => gcd (proj1_sig (mod' n m')) m
end.
(* �����̏ؖ� *)
intros.
destruct (mod' n m'). simpl.
destruct e as [q [Hn Hm]].
apply Hm.
(* ���b���̏ؖ� *)
Search well_founded.
exact lt_wf.
Defined.

(* 
gcd_ind is defined
...
gcd is defined
gcd_equation is defined
�֐��ƈꏏ�ɁC�l�X�ȕ�肪��`�����D���ɁCgcd ind �Ƃ����A�[�@�̌����� functional
induction (gcd m n) �Ƃ������Ŗ��ɗ��D
*)

Extraction "gcd.ml" gcd.
Check gcd_ind.

(* �ł́C���ꂩ�琳�������ؖ�����D*)
Inductive divides (m : nat) : nat -> Prop := (* m �� n ������ *)
divi : forall a, divides m (a * m).
(* ��̒�`���g���₷�����邽�߂̕�� *)
Lemma divide : forall a m n, n = a * m -> divides m n.
Proof. intros. rewrite H. constructor. Qed.

Lemma divides_mult : forall m q n, divides m n -> divides m (q * n).
Proof. induction 1. apply (divide (q*a)). ring. Qed.

Parameter divides_plus :
forall m n p, divides m n -> divides m p -> divides m (n+p).

Parameter divides_1 : forall n, divides 1 n.
Parameter divides_0 : forall n, divides n 0.
Parameter divides_n : forall n, divides n n.

Hint Resolve divides_plus divides_mult divides_1 divides_0 divides_n.

Theorem gcd_divides : forall m n,
divides (gcd m n) m /\ divides (gcd m n) n.
Proof.
  intros.
  functional induction (gcd m n). (* �֐��̒�`�ɑ΂���A�[�@ *)
  auto.
  destruct (mod' n m').
  simpl in *. (* ������P�������� *)
  destruct e as [q [Hn Hm]].
  destruct IHn0.
  split; auto.
  rewrite Hn.
  auto.
Qed.

Parameter plus_inj : forall m n p, m + n = m + p -> n = p.
Lemma divides_plus' : forall m n p,
divides m n -> divides m (n+p) -> divides m p.
Proof.
  induction 1.
  intro.
  induction a. assumption.
  inversion H.
  destruct a0.
  destruct p. auto.
  elimtype False.
  destruct m; destruct a; try discriminate; omega.
  simpl in H1.
  apply IHa.
  rewrite <- plus_assoc in H1.
  rewrite <- (plus_inj _ _ _ H1).
  constructor.
Qed.

Theorem gcd_max : forall g m n,
divides g m -> divides g n -> divides g (gcd m n).
Proof.
Admitted.

(* ���K��� 3.1 Parameter �� Theorem �ɕς��C�ؖ�������������D*)
