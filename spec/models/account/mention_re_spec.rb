# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::MENTION_RE do
  it 'matches usernames in the middle of a sentence' do
    expect(subject.match('Hello to @alice from me')[1]).to eq 'alice'
  end

  it 'matches usernames in the beginning of status' do
    expect(subject.match('@alice Hey how are you?')[1]).to eq 'alice'
  end

  it 'matches full usernames' do
    expect(subject.match('@alice@example.com')[1]).to eq 'alice@example.com'
  end

  it 'matches full usernames with a dot at the end' do
    expect(subject.match('Hello @alice@example.com.')[1]).to eq 'alice@example.com'
  end

  it 'matches dot-prepended usernames' do
    expect(subject.match('.@alice I want everybody to see this')[1]).to eq 'alice'
  end

  it 'does not match e-mails' do
    expect(subject.match('Drop me an e-mail at alice@example.com')).to be_nil
  end

  it 'does not match URLs' do
    expect(subject.match('Check this out https://medium.com/@alice/some-article#.abcdef123')).to be_nil
  end

  it 'does not match URL query string' do
    expect(subject.match('https://example.com/?x=@alice')).to be_nil
  end

  it 'matches usernames immediately following the letter ß' do
    expect(subject.match('Hello toß @alice from me')[1]).to eq 'alice'
  end

  it 'matches usernames containing uppercase characters' do
    expect(subject.match('Hello to @aLice@Example.com from me')[1]).to eq 'aLice@Example.com'
  end
end
