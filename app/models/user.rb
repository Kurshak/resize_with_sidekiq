# frozen_string_literal: true

class User < ApplicationRecord
  MAX_SIZE = 30_000_000

  devise :database_authenticatable, :registerable,
         :rememberable, :validatable
  has_one_attached :avatar
  validates_plausible_phone :phone
  validate :correct_image_mime_type
  validate :check_image_dimensions

  def check_image_dimensions
    if avatar.attached? && avatar.blob.byte_size > MAX_SIZE
      errors.add :to_big_image, 'to_big_image'
    end
  end

  def correct_image_mime_type
    if avatar.attached? && !avatar.content_type.in?(%w[image/png image/jpg image/jpeg])
      errors.add :wrong_format_image, 'wrong_format_image'
    end
  end

  def resize_image
    filename = avatar.filename.to_s
    puts attachment_path = "#{Dir.tmpdir}/#{avatar.filename}"
    File.open(attachment_path, 'wb') do |file|
      file.write(avatar.download)
      file.close
    end
    mini_image = MiniMagick::Image.open(attachment_path)
    mini_image.resize '300!x300!'
    mini_image.write attachment_path
    avatar.attach(io: File.open(attachment_path), filename: filename, content_type: 'image/jpg')
  end 
end
