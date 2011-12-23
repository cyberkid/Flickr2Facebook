require 'job' 

class Worker < ActiveRecord::Base
  
  def self.upload_loop
    while true
      sleep 1
       unprocessed_photos = Photo.where("status = ?", FlickrController::PHOTO_NOTPROCESSED)
       unprocessed_photos.each do |photo|
         photoset = Photoset.find(photo.photoset_id)
         user     = User.find(photoset.user_id)
         job      = Job.new(user.fb_session, user.flickr_oauth_token, user.flickr_oauth_secret)              
         job.upload(photo)
       end
       break
    end
  end
  
  def self.split_sets_loop
    while true
      sleep 1
      unprocessed_sets = Photoset.where("status = ?", FlickrController::PHOTOSET_NOTPROCESSED)
      unprocessed_sets.each do |set| 
        puts "Doing set " + set.photoset
        user = User.find(set.user_id)
        job  = Job.new(user.fb_session, user.flickr_oauth_token, user.flickr_oauth_secret)
        job.upload_set(set.photoset)
      end
      break
    end
  end
end