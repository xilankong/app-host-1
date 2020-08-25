FROM ruby:2.5.1

ENV RAILS_ENV production

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        imagemagick \
        libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN gem sources --add https://gems.ruby-china.com --remove https://rubygems.org/

RUN gem install bundler

WORKDIR /app

ADD Gemfile* ./
RUN bundle install
COPY . .

RUN if [ -f shared/production.sqlite3 ];then mv shared/production.sqlite3 db/production.sqlite3 ; fi

# 数据库初始化
RUN if [ ! -f db/production.sqlite3 ];then rake db:create ; fi
RUN rake db:migrate

# 编译静态文件
RUN rake assets:precompile

EXPOSE 8686

CMD /bin/bash docker/ln_shared_files.sh && puma -C config/puma.rb
