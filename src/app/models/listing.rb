class Listing < ApplicationRecord
  belongs_to :profile
  belongs_to :hobby
  belongs_to :city
  enum equipment: [:yes, :no]
  has_many :attendees
  has_many :listing_attendees, source: :profile, through: :attendees
  has_many :favorites
  has_many :favorited, source: :profile, through: :favorites

  def self.search(search, city)
    scope = all
    if search.present?
      hobby = Hobby.find_by(name: search)
      scope = scope.where(hobby_id: hobby) if hobby
    end
    if city.present? && city != [""] && city.to_s != ""
      scope = scope.where(city_id: city)
    end
    scope
  end
end
