
(* �� *)
Require Import ssreflect.

Section Koushin.

Variables P Q : Prop.

Theorem modus_ponens : P -> (P -> Q) -> Q.
Proof.
  by move=> p; apply.
Qed.

Theorem DeMorgan : ~ (P \/ Q) -> ~ P /\ ~ Q.
Proof.
  move=> npq.
  by split=> [p|q]; apply npq; [left | right].
Qed.

Theorem and_comm : P /\ Q -> Q /\ P.
Proof.
  by move=> [p q]; split.
Qed.

End Koushin.

Module Plus.

Lemma plus_assoc m n p : m + (n + p) = (m + n) + p.
Proof.
elim: m => [|m IHm] //=.
by rewrite IHm.
Qed.
End Plus.

(* 3 MathComp �̃��C�u����
��T�� ssreflect �̃R�}���h���������AMathComp �̖{���̋����͂��̃��C�u�����ɂ���B����
�傫�ȓ����͏����������ؖ��̊�{��@�Ƃ��邱�ƁB
���C�u������ ssreflect, fingroup, algebra ���A�������̂̕�������ł��Ă���B�O�҂�
��ʓI�ȃf�[�^�\���ŁA��҂͑㐔�n�̏ؖ��Ɏg���B

��{�f�[�^
�܂��Assreflect ��ǂݍ��ށB����قǑ����͂Ȃ��B*)

From mathcomp Require Import
     ssreflect ssrbool ssrnat ssrfun seq eqtype choice fintype.
(*
ssrbool �͘_�����Əq��̈����Bssrnat �͎��R���Bssrfun �͊֐� (�ʑ�) �̗l�X�Ȑ����Bseq �̓��X�g�Beqtype, choice, fintype �͂��ꂼ�ꓙ�����A�I���A�L�������g����f�[�^�\���̂�
�߂̘g�g�݂�񋟂��Ă���B�Ⴆ�΁A���R���̓������͔���ł���̂ŁA�r���������肵�Ȃ���
���ꍇ�������ł���B
���g�ɂ��āA�t�@�C�����Q�Ƃ��邵���Ȃ����A�܂� ssrnat �̗���݂悤�B(���Ȃ݂ɁA�\�[
�X�t�@�C���͂�~/.local/share/coq/mathcomp/ssreflect �̉��ɂ���) *)
Module Test_ssrnat.
Fixpoint sum n := if n is m.+1 then n + sum m else 0.

Theorem sum_square n : 2 * sum n = n * n.+1.
Proof.
  elim: n => [|n IHn] /=.
  done.
  rewrite mulnDr.
  rewrite -[n.+2]addn2 mulnDr.
  rewrite [n.+1*n]mulnC -IHn.
  by rewrite addnC (mulnC _ 2).
Qed.
End Test_ssrnat.

(* ���Ȕ��f
�_���������������ŏ����������B���̂��߂ɁAssrbool �ł͘_�����Z�q���^ bool �̏�̉��Z�q�Ƃ��Ē�`���Ă���B�Ⴆ�΁A/\ ��&&, \/ ��||�ɂȂ�B��̒�`�̊Ԃɍs�������邽�߂ɁA
reflect �Ƃ������Ȕ��f��\�����錾���g���B���ꂪ SSReflect �̖��O�̗R���ł���B *)
Print reflect.
Inductive reflect (P : Prop) : bool -> Set :=
ReflectT : P -> reflect P true | ReflectF : ~ P -> reflect P false.
Check orP.
(* orP : forall b1 b2 : bool, reflect (b1 b2) (b1 || b2) *)

(* �\���̐؂�ւ��̓r���[�@�\�ɂ���čs����B�O�Ɍ����K�p�p�^�[�����g���Bmove, case,
apply �Ȃǂ̒����/view ��t����ƁA�Ώ����\�ȕ����ɕϊ������B=>�̉E�ł��g����B��
���A�r���[�Ƃ��Ă͏�� reflect �^ ���łłȂ��A���l�֌W (P <-> Q) �╁�ʂ̒藝 (P -> Q) ���g����B *)
Module Test_ssrbool.
Variables a b c : bool.
Print andb.

Lemma andb_intro : a -> b -> a && b.
Proof.
  move=> a b.
  rewrite a.
  move=> /=.
  done.
  Restart.
  by move ->.
Qed.

Lemma andbC : a && b -> b && a.
Proof.
  case: a => /=.
  by rewrite andbT.
  done.
  Restart.
  by case: a => //= ->.
  Restart.
  by case: a; case: b.
Qed.

Lemma orbC : a || b -> b || a.
Proof.
  case: a => /=.
  by rewrite orbT.
  by rewrite orbF.
  Restart.
  move/orP => H.
  apply/orP.
  move: H => [Ha|Hb].
  by right.
  by left.
  Restart.
  by case: a; case: b.
Qed.

Lemma test_if x : if x == 3 then x*x == 9 else x !=3.
Proof.
  case Hx: (x == 3).
  by rewrite (eqP Hx).
  done.
  Restart.
  case: ifP.
  by move/eqP ->.
  move/negbT. done.
Qed.
End Test_ssrbool.

(* ���Ȕ��f������Ǝ��R���̏ؖ����X���[�Y�ɂȂ�B*)
Theorem avg_prod2 m n p : m+n = p+p -> (p - n) * (p - m) = 0.
Proof.
  move=> Hmn.
  have Hp0 q: p <= q -> p-q = 0.
  by rewrite -subn_eq0 => /eqP.
  suff /orP[Hpm|Hpn]: (p <= m) || (p <= n).
  + by rewrite (Hp0 m).
  + by rewrite (Hp0 n).
  case: (leqP p m) => Hpm //=.
  case: (leqP p n) => Hpn //=.
  suff: m + n < p + p.
  by rewrite Hmn ltnn.
  by rewrite -addnS leq_add // ltnW.
Qed.

(* ���w�֌W�̒藝
������̓��W���[�������߂��āA�ȒP�ɏЉ�ł���B�悭�g�������Ƃ��āAfinset(fintype �Ɋ���L���W���A��{�I�Ȑ��`�㐔�� matrix�Aperm �� vector�A�������� poly�A�f���� prime�B*)

(* ���K��� 3.1 ���܂ł̉ۑ�� SSReflect �̍\�����g���ď��������Ă݂�B *)

