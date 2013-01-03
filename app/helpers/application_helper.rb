module ApplicationHelper
  
  def menuArea(email, is_yours)
    profile = Profile.where("email =?", email ).first
    content_tag(:div, :class => "menuArea") do
      concat tag("br")
      concat(content_tag(:center) do
        image_tag(profile.photo.url(:small), :class => "profilepic")
      end)
      concat tag("br")
      concat tag("br")
      concat(content_tag(:center) do
        concat(content_tag(:b) do
          concat email.split('@')[0]
          concat '@'
          concat email.split('@')[1]
          concat tag("br")
          concat email.split('@')[2]
        end)
      end)
      concat tag("br")
      concat tag("br")
      concat(content_tag(:center) do
        concat(content_tag(:div, :class => "menu") do
          if is_yours then
            concat link_to('Your home', my_profile_path)
            concat tag("br")
            concat link_to('Private messages', messages_overview_path)
            concat tag("br")
            concat link_to('Your friends', friends_path) 
            concat tag("br")
            concat tag("br")
            concat link_to('Edit your profile', profile_edit_path)
            concat tag("br")
          else
            #concat link_to('View home', "profiles?email=" + email)
            #oncat tag("br")
            #concat link_to('Send private message', messages_overview_path)
            #concat tag("br")
            #concat link_to('View friends', friends_path)
            #concat tag("br")
            if session[:remote_user_email] then
              concat link_to('Back to your Home', '/profiles/?email=' + session[:remote_user_email])
            else
              concat link_to('Back to your Home', '/profiles/?email=' + current_user.email)
            end
          end
        end)
      end)
      concat tag("br")
      # if !is_yours then
        # concat(content_tag(:center) do
          # concat(content_tag(:div, :class => "menu") do
            # if session[:remote_user_email] then
              # concat link_to('Back to your Home', 'profiles?email=' + session[:remote_user_email])
            # else
              # concat link_to('Back to your Home', 'profiles?email=' + current_user.email)
            # end
          # end)
        # end)
        # concat tag("br")
      # end
    end
  end
  
  def major_block(title, date=nil, &block)
    content_tag(:div, :class => "major_block_wrapper") do
      concat major_block_headline(title, date)
      concat(content_tag(:div, :class => "major_block_text") do
        concat capture(&block)
      end)
    end
  end
  
  def major_block_headline(title, date=nil)
    content_tag(:div, :class => "major_block_headline") do
      concat(content_tag(:span, :class => "major_block_title") do
        concat title
      end)
      if date then
        concat(content_tag(:span, :class => "major_block_date") do
          concat date
        end)
      end
      concat clear_float
    end
  end
  
  def clear_float()
    tag(:br, :class => "float_clear")
  end
  
end
