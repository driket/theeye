FROM ruby
RUN gem install sinatra
RUN gem install thin
ADD ds_manager.rb /
CMD ["ruby", "ds_manager.rb"]
EXPOSE 80
