FROM jenkins/jenkins:lts

USER root
RUN apt-get update && apt-get install -y ruby 
#USER jenkins 
RUN gem install rspec &&\
gem install serverspec  &&\
gem install docker  &&\
gem install aws-sdk  --no-rdoc --no-ri
