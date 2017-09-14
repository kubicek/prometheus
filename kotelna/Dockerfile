FROM ruby:2.3.3
RUN apt-get update -qq && apt-get install -y build-essential
RUN mkdir /kotelna
WORKDIR /kotelna
ADD . /kotelna
RUN bundle install
