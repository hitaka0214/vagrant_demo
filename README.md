vagrant demo
============

# 概要
Vagrant+Chefを使ってCentOS 7の仮想マシンを構築します。  
また，ServerSpecを使って，構築後のサーバのテストを行います。

# 検証環境
OS: OS X Maverics 10.9.4  
VirtualBox 4.3.14  
Vagrant 1.6.3  

# 利用手順
## (初回のみ)vagrantのプラグインをインストールする。
```
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-serverspec
```

## (初回のみ)任意のディレクトリ上でgit repositoryをcloneする。
```
git clone https://github.com/hitaka0214/vagrant_demo.git
```

## vagrantを作成・起動する。
```
cd vagrant_demo
vagrant up
```

## 構築した仮想マシンへログインする。
```
vagrant ssh
```
exitすればサーバからログアウト可能。

## 仮想マシンを停止する場合
```
vagrant halt
```

## 仮想マシンを削除する場合
```
vagrant destroy
```

# Chefコード説明
## init::swap
swapファイルを作成する。

## init::devenv
* vimのインストールと設定ファイルの設置。
* screenのインストールと設定ファイルの設置。
* emacsのインストールと設定ファイルの設置。

## init::nginx
* nginxのリポジトリをインストール。
* nginxをインストール。
* nginxのサービスを起動。また，自動起動設定。
* firewalld（旧iptables）の停止。（port 80の通信を止められているため）

## init::docker
* dockerをインストール。
* dockerのサービスを起動。また，自動起動設定。
* Dockerfileをレシピからコピー。

## dev::projectx
* projectxディレクトリを作成し，このgitリポジトリをclone。
* nginx用の設定ファイルをレシピからコピー。
* /home/vagrantのパーミッションを変更。  
http://192.168.50.10/thecodes/へアクセス可能になる。


