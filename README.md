# ZaZaar

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && yarn install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix

## V.1 User Flow

#### 1.直播主開始直播
-> 打開 ZaZaar 創一個新的 Stream 開始收集訂單

#### 2.直播主完成直播
-> Stream 進入 Pending

-> 這個時候可以修改每一個成立的 Stream Merchandises

#### 3.直播主點成立訂單
-> Stream 進入 Complete

-> Stream Merchandises 變成不能修改

-> ZaZaar 用這些 Stream Merchandises 成立 Orders

-> 寄出 FB 訊息給買家 with invoice link

#### 4.如果要修改 Order
-> 買賣雙方自行透過 FB 訊息溝通、取得共識

-> 透過增加 Order Items 的方式 來改變 invoice 金額(ie. XXX免運 -$1300, 另外購買YYY $2000)

-> Order 可以被 Void（廢除） 掉

#### 5.Order 完成後
-> 直播主可以手動把 Order complete 掉
