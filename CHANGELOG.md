#### Umbrella 프로젝트 생성
```shell
$ mix new babel --umbrella
```

#### OTP app 생성
```shell
$ cd babel/apps
$ mix new trans --sup
```

#### Phoenix app 생성
```shell
$ cd ../
$ mix local.hex
$ mix archive.install https://github.com/phoenixframework/archives/raw/master/phx_new.ez

$ cd apps
$ mix phx.new babel

... 데이터베이스 설정 ...

$ cd ../
$ mix ecto.create
```

#### User schema 생성
```shell
$ cd apps/babel
$ mix phx.gen.schema Accounts.User users email:string password_hash:string name:string is_admin:boolean
$ mix ecto.migrate
```

#### Chat.Room context 생성
```shell
$ mix phx.gen.html Chat Room rooms title:string description:text user_id:references:users
```

#### Chat.Message schema 생성
```shell
$ mix phx.gen.schema Chat.Message messages room_id:references:rooms user_id:references:users body:string
```

#### Gettext 설정 (for I18n support)
```shell
$ mix gettext.extract
$ mix gettext.merge priv/gettext
$ mix gettext.merge priv/gettext --locale ko
# OR
$ mix gettext.extract --merge



```