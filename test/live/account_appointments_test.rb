# frozen_string_literal: true

require_relative 'live_helper'

class AccountAppointmentsLiveTest < ZmTest::LiveTest
  def start_time
    @start_time ||= begin
      tomorrow = Time.now.utc + 86_400
      Time.utc(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0, 0)
    end
  end

  def create_appointment(name = unique_name('appointment'), **attrs)
    appointment = account.appointments.new do |appt|
      appt.name = name
      appt.l = Zm::Client::FolderDefault::CALENDAR.id
      appt.timezone = 'UTC'
      appt.start_at = start_time
      appt.end_at = start_time + 3_600
      appt.body.text = 'Live Test body'
      attrs.each { |key, value| appt.public_send(:"#{key}=", value) }
    end
    appointment.create!
    appointment
  end

  def search_appointments(folder_id = Zm::Client::FolderDefault::CALENDAR.id)
    account.appointments
           .folder_ids(folder_id)
           .start_at(start_time - 86_400)
           .end_at(start_time + (2 * 86_400))
           .all
  end

  def search_appointment(name, folder_id = Zm::Client::FolderDefault::CALENDAR.id)
    search_appointments(folder_id).find { |appt| appt.name == name }
  end

  def test_create
    appointment = create_appointment

    refute_nil appointment.id
    refute_nil appointment.calItemId
    refute_nil appointment.invId
  end

  def test_read
    name = unique_name('appointment')
    appointment = create_appointment(name)
    found = account.appointments.find(appointment.id)

    assert_kind_of Zm::Client::Appointment, found
    assert_equal name, found.name
    assert_equal start_time.to_i, found.start_at.to_i
    assert_equal (start_time + 3_600).to_i, found.end_at.to_i
    refute_nil found.uid
  end

  def test_search
    name = unique_name('appointment')
    create_appointment(name)
    found = search_appointment(name)

    refute_nil found
    assert_equal start_time.to_i, found.start_at.to_i
    assert_equal 3_600, found.dur
  end

  def test_create_all_day
    appointment = create_appointment(allDay: true)
    found = account.appointments.find(appointment.id)

    assert found.allDay
  end

  def test_create_with_attendee
    attendee_email = 'attendee@example.com'
    appointment = account.appointments.new do |appt|
      appt.name = unique_name('appointment')
      appt.l = Zm::Client::FolderDefault::CALENDAR.id
      appt.timezone = 'UTC'
      appt.start_at = start_time
      appt.end_at = start_time + 3_600
      appt.organizer = Zm::Client::Appointment::Organizer.new(account.name)
      appt.attendees.add(Zm::Client::Appointment::Attendee.new(attendee_email))
    end
    appointment.create!
    found = account.appointments.find(appointment.id)

    assert_equal account.name, found.organizer.email
    assert_includes found.attendees.map(&:email), attendee_email
  end

  def test_modify
    appointment = create_appointment
    found = account.appointments.find(appointment.id)
    new_name = unique_name('modified')
    found.name = new_name
    found.l = Zm::Client::FolderDefault::CALENDAR.id

    assert found.modify!
    assert_equal new_name, account.appointments.find(appointment.id).name
  end

  def test_move
    folder = account.folders.new do |f|
      f.name = unique_name('calendar')
      f.view = Zm::Client::FolderDefault::CALENDAR.type
    end
    folder.create!
    name = unique_name('appointment')
    create_appointment(name)
    search_appointment(name).move!(folder.id)

    assert_nil search_appointment(name)
    refute_nil search_appointment(name, folder.id)
  end

  def test_tags
    tag = account.tags.new { |t| t.name = unique_name('tag') }
    tag.create!
    name = unique_name('appointment')
    create_appointment(name)
    appointment = search_appointment(name)

    assert appointment.tags.add!(tag.name)
    assert_includes search_appointment(name).tags.all, tag.name
  end

  def test_delete
    name = unique_name('appointment')
    create_appointment(name)
    search_appointment(name).delete!

    assert_nil search_appointment(name)
  end
end
