# Change_log
##... 180628 to do
Green と Pink で表示している Excitatory/ Inhitiory cell map と
Direction/Orientation selective map を比べると位置がおかしい？？？ 
cell map にないのに， selective map にある．みたいな．要チェック．
と思ったけど，response map は non-selective cell を色分けしてるだけか．．．

Eye velocity の縦軸を変更する？
時間軸を color gradation に対応させているけど，必要ないか（表示が軽くできるかも？）


##... 180424
fit_DS_tuning.m での OS での centering を修正．
max(nanmax(dFF_s_each)) を基準にしていたが， max(max(dFF_s_ave)) の方が良さそう．

##... 180423
Edit_tuning で dFF_s_ave と dFF_s_each も編集するようにした．
DS cell の場合は， Pref direction を基準に fitting するけど
Pref orientation を基準にした方が double gaussian の fit が
良い場合もあるのは，どうするべきか？

Mod_Trial_Averages で tuning 編集する時
dFF_ext から読み込むので安全ではあるのだけど編集後に posi-nega が反転する場合は
ループになってしまう．．．ex) SC3, roi 20


##... 180420
Orientation を double gaussian fit する時 の centering を変更

##... 180418
一応，変な data を編集する flow を作ったが，まだ manual すぎるきがする．

##... 180417
DStuning と OS tuning 別でファイルに分ける．
dFF_s_each にある以上なresponse のチェックように Delete_event.m を作成
Delete 後に selctivity も再計算する必要があるので， Get_Trial_Average で tuning properties
計算するところを 別の関数に分ける．

## 11.5（にする）... 180410
Open2P.m で呼んでいた Trial average 等の計算 と plot の 関数を分けた．
Oversampling して plot するのは 一旦やめる．
trial ごとの peak value を imgobj.dFF_s_each に保存．
trial average は imgobj.dFF_s_ave に入れる．

## 11.0.4... todo
stim average は selectROI は 複数にして imagesc にする．それとは別に
stim タイプごとの subplot を n で見てるやつで表示

## 11.0.3
Rec11 で保存した mat データの読み込み．
Two-photon のタイムラプス画像から抜き出した dFF データ（.xls: 行=フレーム，列=ROI)．
plot_next で 眼球データの更新，テーブルの更新
GUI(two-photon) はタイミング補正 OK

# To Do
## 170119
テーブル情報を刺激パタンごとに完成．
刺激タイミングの補正の計算．(刺激タイミングで縦線入れたい？)
global 変数のチェック


