module ApplicationHelper
  
  def menuArea(profile, is_yours)
    content_tag(:div, :class => "menuArea") do
      concat tag("br")
      concat(content_tag(:center) do
        image_tag(@profile.photo.url(:small), :class => "profilepic")
      end)
      concat tag("br")
      concat tag("br")
      concat(content_tag(:center) do
        concat(content_tag(:b) do
          concat @profile.email.split('@')[0]
          concat '@'
          concat @profile.email.split('@')[1]
          concat tag("br")
          concat @profile.email.split('@')[2]
        end)
      end)
      concat tag("br")
      concat tag("br")
      concat(content_tag(:center) do
        concat(content_tag(:div, :class => "menu") do
          if is_yours then
            concat link_to('Your profile', my_profile_path)
            concat tag("br")
            concat "Your Guestbook"
            concat tag("br")
            concat link_to('Private Messages', messages_overview_path)
            concat tag("br")
            concat link_to('Friends', friends_path) 
            concat tag("br")
          else
            concat link_to('Profile', my_profile_path)
            concat tag("br")
            concat "Guestbook"
            concat tag("br")
            concat link_to('Send private Message', messages_overview_path)
            concat tag("br")
            concat link_to('Friends', friends_path) 
            concat tag("br")
          end
        end)
      end)
    end
  end
end
