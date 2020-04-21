---
layout: post
title: "Upgrade Ruby and Rails versions to 2.6.6 and 6.0 respectively"
date: 2020-04-21 16:13:00 -0800
categories: rails, ruby
---
Upgraded the Rails-based applications from `5.1.7` to `6.0.2.2`.

I started by upgrading to the latest version of the Ruby language.  I updated
`.ruby-version` and they ran `bundle update`.  And that was all there was to it.

I then tried to create blank `5.1.7` and `6.0.2.1` apps, the way I usually do
for Grails apps.  But the result didn't work.  There was something conflicted
in the `knock` gem.

For my second attempt, I changed the dependency in `Gemfile` instead and let
Bundler deal with it.  I went from `~> 5.1.7` to `~> 5.0` and after running
`bundle update`, it was upgraded to `5.4.2.4`.  Building on this success, I
changed the dependency once more to `~> 6.0`, which updated me all the way to
version `6.0.2.2`.  I had to deal with a few deprecations and update RSpec, too,
but all the tests are passing and the app is working just fine.
