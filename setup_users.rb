aviva_properties = Property.where(name: 'A'..'B')
ibm_properties = Property.where(name: 'I'..'J')

# create organisations
aviva_ou = Organisation.create! name: 'Aviva'
ibm_ou = Organisation.create! name: 'IBM'

aviva_properties.update_all(organisation_id: aviva_ou)
ibm_properties.update_all(organisation_id: ibm_ou)


# create BNPPRE users
User.where("email like '%.bnppre@example.com'").each(&:destroy)

%w(Brooke Bobby Bella Ben Blake).each do |u|
  User
    .create!(username: u.downcase,
              first_name: u,
              last_name: 'Babbage (BNPPRE)',
              email: "#{u}.bnppre@example.com",
              password: 'password',
              password_confirmation: 'password')
    .organisations << [aviva_ou, ibm_ou]
end

User.find_by_username('brooke').update(admin_user: true)
User.find_by_username('bobby').update(admin_property: true)


# create Aviva users
User.where("email like '%.aviva@example.com'").each(&:destroy)

%w(Amelia Alfie Ava Archie).each do |u|
  User
    .create!(username: u.downcase,
              first_name: u,
              last_name: 'Adams (AVIVA)',
              email: "#{u}.aviva@example.com",
              password: 'password',
              password_confirmation: 'password')
    .organisations = [aviva_ou]
end

User.find_by_username('amelia').update(admin_user: true)
User.find_by_username('alfie').update(admin_property: true)


# reset properties so that they are not deleted or archived
Property.unscoped.update_all deleted: false
Property.unscoped.update_all archived: false


# create access groups
AccessGroup.destroy_all

edit_template = AccessTemplate.find_by_name('Edit property, view spaces')
edit_with_leases_template = AccessTemplate.find_by_name('Edit property, view leases and spaces')
read_template = AccessTemplate.find_by_name('Read all')

bnppre_select_properties = aviva_properties.first(5) + ibm_properties.first(2)
aviva_select_properties = aviva_properties.first(2) + aviva_properties.last(5)

group = AccessGroup.create!(name: 'All BNPPRE', access_template: edit_template)
group.users << User.where(username: %w(brooke bobby))
group.add_property Property.all

group = AccessGroup.create!(name: 'BNPPRE Occupier Mgmt editors', access_template: edit_with_leases_template)
group.users << User.where(username: %w(brooke bella ben))
group.add_property bnppre_select_properties

group = AccessGroup.create!(name: 'BNPPRE Occupier Mgmt readers', access_template: read_template)
group.users << User.where(username: %w(brooke blake))
group.add_property bnppre_select_properties

group = AccessGroup.create!(name: 'All Aviva', access_template: edit_template)
group.users << User.where(username: %w(amelia alfie))
group.add_property aviva_properties

group = AccessGroup.create!(name: 'Aviva Occupier Mgmt editors', access_template: edit_with_leases_template)
group.users << User.where(username: %w(amelia ava))
group.add_property aviva_select_properties

group = AccessGroup.create!(name: 'Aviva Occupier Mgmt readers', access_template: read_template)
group.users << User.where(username: %w(amelia archie))
group.add_property aviva_select_properties
