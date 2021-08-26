# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ExConductor.Repo.insert!(%ExConductor.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias ExConductor.Accounts

users = [
  %{
    email: "michael@test.com",
    username: "michael",
    password: "password12345"
  },
  %{
    email: "lauren@test.com",
    username: "lauren",
    password: "password12345"
  },
  %{
    email: "jeffrey@test.com",
    username: "jeffrey",
    password: "password12345"
  },
  %{
    email: "adam@test.com",
    username: "adam",
    password: "password12345"
  },
  %{
    email: "admin@test.com",
    username: "admin",
    password: "password12345",
    is_admin: true
  }
]

Enum.each(users, &Accounts.register_user/1)
