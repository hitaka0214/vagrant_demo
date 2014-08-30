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
1. (初回のみ)vagrantのプラグインをインストールする。
```
vagrant plugin install vagrant-omnibus
vagrant plugin install vagrant-serverspec
```

2. (初回のみ)任意のディレクトリ上でgit repositoryをcloneする。
```
git clone https://github.com/hitaka0214/vagrant_demo.git
```

3. vagrantを作成・起動する。
```
cd vagrant_demo
vagrant up
```

4. 構築した仮想マシンへログインする。
```
vagrant ssh
```
exitすればサーバからログアウト可能。

5. 仮想マシンを停止する場合
```
vagrant halt
```

6. 仮想マシンを削除する場合
```
vagrant destroy
```


