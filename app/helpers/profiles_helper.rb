module ProfilesHelper
  def user_avatar(user, size: 40)
    if user.avatar.attached?
      # Si tiene foto, mostramos redimensionada
      image_tag user.avatar.variant(resize_to_fill: [ size, size ]),
                class: "avatar-img",
                style: "width: #{size}px; height: #{size}px; border-radius: 50%; object-fit: cover;"
    else
      # Si no, cogemos la primera letra de su nombre o email
      initial = (user.name.presence || user.email).first.upcase

      # Ciculo avatar
      content_tag :div, initial,
                  class: "avatar-placeholder",
                  style: "width: #{size}px; height: #{size}px; border-radius: 50%; background-color: #0277bd; color: white; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: #{size / 2}px;"
    end
  end
end
