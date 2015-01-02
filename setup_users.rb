# create Aviva users
User.where("email like '%.aviva@example.com'").each(&:destroy)

%w(Angus Alice Alison).each do |u|
  User.create!(username: u,
              first_name: u,
              last_name: 'Alpha',
              email: "#{u}.aviva@example.com",
              password: 'password',
              password_confirmation: 'password')
end

User.find_by_username('Angus').update(admin_user: true)


# create BNPPRE users
User.where("email like '%.bnppre@example.com'").each(&:destroy)

%w(Brian Bob Ben).each do |u|
  User.create!(username: u,
              first_name: u,
              last_name: 'Bravo',
              email: "#{u}.bnppre@example.com",
              password: 'password',
              password_confirmation: 'password')
end

User.find_by_username('Brian').update(admin_user: true)


# create access groups
AccessGroup.destroy_all

template = AccessTemplate.find_by_name('Edit all')

group = AccessGroup.create!(name: 'All Aviva', access_template: template)
group.users << User.where(username: %w(Angus Alice Alison))
group.add_property Property.where(name: 'A'..'C')

group = AccessGroup.create!(name: 'All BNPPRE', access_template: template)
group.users << User.where(username: %w(Brian Bob Ben))
group.add_property Property.where(name: 'C'..'E')
