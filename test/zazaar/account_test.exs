defmodule ZaZaar.AccountTest do
  use ZaZaar.DataCase

  doctest ZaZaar.Account

  describe "get_user/1" do
    test "gets user from user id" do
      user = insert(:user)

      result = Account.get_user(user.id)

      assert user.id == result.id
    end

    test "get user from fb_id" do
      user = insert(:user, fb_id: "foobar")

      assert Account.get_user(fb_id: user.fb_id) |> Map.get(:fb_id) == user.fb_id
    end
  end

  describe "set_user/2" do
    test "if map is passed in as single arugment, insert a user" do
      params = params_for(:user)
      assert {:ok, %User{} = user} = Account.set_user(params)
      assert user.name == params.name
    end

    test "if no user is given, insert a user" do
      params = params_for(:user)
      assert {:ok, %User{} = user} = Account.set_user(nil, params)
      assert user.name == params.name
    end

    test "if user is given, update the user" do
      user = insert(:user, name: "foo")
      params = %{name: "bar"}
      assert {:ok, %User{} = user1} = Account.set_user(user, params)
      assert user.name != params.name
    end
  end
end
