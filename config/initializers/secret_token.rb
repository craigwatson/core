# This file was generated by 'rake generate_secret_token', and should
# not be made visible to public.

# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

BuckyBox::Application.config.secret_token = if Rails.env.development? || Rails.env.test?
  "0e8a5b92da228e886c8879ee7dd5935341736db44030ccac1b77202af5018a8d41feaef7ac0fe80103d90f676e658753c20b84a62b412cfc473458a01f21b8ea"
else
  # XXX: a token is needed to run db:migrate so we generate a random one
  require "securerandom"
  ENV.fetch("SECRET_TOKEN", SecureRandom.hex(64))
end
