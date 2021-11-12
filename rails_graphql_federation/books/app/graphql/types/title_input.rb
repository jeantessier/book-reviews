module Types
  class TitleInput < Types::BaseInputObject
    argument :title, String, required: true
    argument :link, String, required: false
  end
end
