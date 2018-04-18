# Change_log
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


