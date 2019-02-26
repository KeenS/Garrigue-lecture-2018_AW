
(*
���b�A�[�@�̌���
�O��͐��b�A�[�@�ɂ��֐��̒�`�������B���R�Ȃ���A���b�A�[�@�͒藝�̏ؖ��ɂ��g����B
 *)

Require Import Wf_nat.
Check lt_wf_ind.
(* : forall (n : nat) (P : nat -> Prop),
   (forall n0 : nat, (forall m : nat, m < n0 -> P m) -> P n0) -> P n *)

Goal forall n, n + 0 = n.
induction n using lt_wf_ind. (* induction ... using ... �Ŏg�� *)
destruct n.
reflexivity.
simpl.
f_equal.
apply H.
auto.
Qed.


(* �{�藝�̏ؖ� *)
Require Import Arith Wf_nat Omega.
(* �����ɂ��Ă̗l�X�ȕ�� *)
Module Div2.
Definition double n := n + n.

Fixpoint div2 (n : nat) :=
match n with
  | 0 | 1 => 0
  | S(S n') => S (div2 n')
end.

Check plus_n_Sm.

Parameter double_div2: forall n, div2 (double n) = n.
Parameter double_inv: forall n m, double n = double m -> n = m.

Theorem double_mult_l: forall n m, double (n * m) = double n * m.
  unfold double. auto with arith.
Qed.

Theorem double_mult_r: forall n m, double (n * m) = n * double m.
  unfold double; intros; ring.
Qed.

Lemma div2_le : forall n, div2 n <= div2 (S n) <= S (div2 n).
  induction n. split. auto. auto. (* ���� /\ �łȂ����Ă��� *)
  destruct IHn.
Admitted.

Lemma div2_lt : forall n, n <> 0 -> div2 n < n.
Proof.
  induction n; intros.
  elim H; auto.
  destruct n; simpl.
  auto.
  destruct (div2_le n).
  apply lt_n_S.
  eauto using le_lt_trans.
Qed.

End Div2.

Import Div2.

Notation double' := double.

(* �����ɂ��� *)
Require Import Even. (* �W�����C�u������ Even ���g�� *)
Print even. (* ���ƂŌ������̂ƈႢ�A���ݍċA�Œ�`����Ă��� *)
(* Inductive even : nat -> Prop :=
  | even_O : even 0
  | even_S : forall n : nat, odd n -> even (S n)
  with odd : nat -> Prop :=
  | odd_S : forall n : nat, even n -> odd (S n) *)

Theorem even_is_even_times_even: forall n, even (n * n) -> even n.
  intros.
  destruct (even_or_odd n). auto.
  eapply even_mult_inv_r; eauto.
Qed.

Parameter double_even : forall n, even (double n).
(* ���݋A�[�@�̌����𐶐����� *)
Scheme even_odd_ind := Induction for even Sort Prop
with odd_even_ind := Induction for odd Sort Prop.

Check even_odd_ind. (* even �� odd �̗����ɑ΂��ďq������ *)
(* : forall (P : forall n : nat, even n -> Prop)
   (P0 : forall n : nat, odd n -> Prop),
   P 0 even_O ->
   (forall (n : nat) (o : odd n), P0 n o -> P (S n) (even_S n o)) ->
   (forall (n : nat) (e : even n), P n e -> P0 (S n) (odd_S n e)) ->
   forall (n : nat) (e : even n), P n e *)

Lemma even_double : forall n, even n -> double (div2 n) = n.
Proof.
eapply even_odd_ind. (* odd �̏q�ꂪ�܂�������Ȃ� *)
reflexivity.
intros.
apply H. (* odd �ɂ��ĉ�������̂܂ܕԂ� *)
Admitted. (* �ؖ������������Ă� *)

(* �{�藝�Ŏg����� *)
Theorem even_square: forall n,
even n -> double (double (div2 n * div2 n)) = n * n.
Admitted.

(* �{�藝 *)
Theorem main_thm: forall n p : nat, n * n = double (p * p) -> p = 0.
Proof.
induction n using lt_wf_ind; intros. (* ���b�A�[�@�̎g���� *)
destruct (eq_nat_dec n 0). (* ���R���Ȃ�A��r�ɂ��Ĕr���������藧�� *)
subst.
destruct p; try discriminate.
auto.
assert (even_n: even n). admit. (* ���������������Ă� *)
assert (even_p: even p). admit.
rewrite <- (even_double p even_p).
rewrite <- (even_double _ even_O).
f_equal. (* ���ӂ̊֐������ *)
apply (H (div2 n)).
Admitted.


(* �������ł��邱�Ƃ̏ؖ� *)
(* �����̐��E�Ɉڂ� *)
Require Import Reals.
Require Import Field. (* �̂ɂ�����P������������ field *)
Print Raxioms.
Check completeness. (* ��łȂ���ɗL�E�ȏW���ɂ͏�������� *)
(* : forall E : R -> Prop,
  bound E -> (exists x : R, E x) -> {m : R | is_lub E m} *)

(* �������̒�` *)
Definition irrational (x : R) : Prop :=
 forall (p : Z) (q : nat), q <> 0 -> x <> (IZR p / INR q)%R.

(* sqrt 2 ���������ł��� *)
Theorem irrational_sqrt_2: irrational (sqrt (INR 2)).
Proof.
  intros p q Hq Hrt.
  elim Hq.
  Check Zabs_nat.
  apply (main_thm (Zabs_nat p)).
  replace (double' (q * q)) with (2 * (q * q))
    by (unfold double'; ring).
  apply INR_eq. (* �����̓����ɕς��� *)
  repeat rewrite mult_INR.
  Check sqrt_def.
  rewrite <- (sqrt_def (INR 2)) by auto with real.
  rewrite Hrt.
  assert (INR q <> 0%R). auto with real.
  destruct p; simpl. field; auto.
    rewrite INR_IPR; unfold IZR. field; auto.
  rewrite INR_IPR; unfold IZR. field; auto.
Qed.

(*
�������ȏؖ�
�܂��ؖ����Ă��Ȃ��������ؖ��������̂悤�Ɉ����ɂ͉��ʂ�̂���������B
 Parameter (�܂��� Axiom �Ȃǂ̓��`��) �Ō����Ƃ��ĉ�����B
 �ؖ��̓r���� Admitted �Ŗ�����ؖ���F�߂�����B����� Qed �ŏI��ꂽ�悤�Ɍ�����B
 �ؖ��̓r���� admit �Ō��݂̃S�[����F�߂�����B���̃S�[���Ɉڂ�B
*)

(* ���K��� 1.1 �ؖ��̒��� Parameter �� Theorem �ɁAAdmitted �� Qed �ɕς��Aadmit ���Ȃ����āA�ؖ�����������B*)
