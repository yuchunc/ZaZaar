defmodule ZaZaar.AuthTest do
  use ZaZaar.DataCase

  alias Ueberauth.Auth, as: UAuth
  alias ZaZaar.Auth

  describe "fb_auth/1" do
    setup do
      info = %{
        email: Faker.Internet.email(),
        name: Faker.Name.name(),
        image: Faker.Avatar.image_url()
      }

      {:ok, uauth: %UAuth{uid: "somefbuid", info: info}}
    end

    test "error if ueberauth struct is not used" do
      assert {:error, :ueberauth_struct_not_used} = Auth.fb_auth(%{})
    end

    test "accepts ueberauth struct, creates user if not exist", ctx do
      %{uauth: uauth} = ctx
      assert {:ok, user} = Auth.fb_auth(uauth)
      assert user.name == uauth.info.name
    end

    test "accepts ueberauth struct, auth user exist", ctx do
      %{uauth: uauth} = ctx
      params = [name: uauth.info.name, fb_id: uauth.uid, email: uauth.info.email]
      user0 = insert(:user, params)
      assert {:ok, user1} = Auth.fb_auth(uauth)
      assert user1.fb_id == user0.fb_id
    end
  end
end
