class Header::Cell < Template::Cell
  include React::Rails::ViewHelper

  def show
    render
  end

  def participant_dropdown
    if current_participant
      dropdown =
        "<div class='user'>
          <a id='toggle-user' href='#'>#{ concept(Image::Cell, current_participant) }</a>
          <div id='user-container'>
            <ul>
              <li>#{ link_to current_participant.name, participant_path(current_participant)}</li>
              <li>#{ link_to 'Account Settings', edit_participant_registration_path }</li>
              <li>#{ link_to 'Log Out', destroy_participant_session_path, :method => :delete }</li>
            </ul>
          </div>
        </div>"
      return dropdown
    end
  end

  def desktop_links
    links = [
      "<ul>",
      "<li>#{ link_to "Challenges", challenges_path }</li>",
      "<li>#{ link_to "Knowledge Base", articles_path }</li>"
    ]

    if current_participant && current_participant.admin?
      links << "<li>#{ link_to "Admin", '/admin' }</li>"
    end

    if current_participant.nil?
      links << "<li>#{ link_to "Sign up", new_participant_registration_path }</li>"
      links << "<li>#{ link_to "Log in", new_participant_session_path }</li>"
    end

    links << "</ul>"
    links.join
  end

  def mobile_links
    links = [
    "<ul>
      <li><h3>#{ link_to "Challenges", challenges_path }</h3></li>
      <li><h3>#{ link_to "Knowledge Base", articles_path }</h3></li>
    </ul>" ]

    if current_participant.nil?
      links << "<ul>
                  <li><h4>#{ link_to "Sign up", new_participant_registration_path }</h4></li>
                  <li><h4>#{ link_to "Log in", new_participant_session_path }</h4></li>
              </ul>"
    else
      links << "<ul>
                  <li>#{ link_to current_participant.name, participant_path(current_participant)}</li>
                  <li>#{ link_to 'Account Settings', edit_participant_registration_path }</li>
                  <li>#{ link_to 'Log Out', destroy_participant_session_path, :method => :delete }</li>
                </ul>"
    end
    links.join
  end
end
