require "cassandra"

class Chronologic::Schema
  attr_accessor :connection

  def create_object(key, attrs)
    connection.insert(:Object, key, attrs)
  end

  def remove_object(object_key)
    connection.remove(:Object, object_key)
  end

  def object_for(object_key)
    case object_key
    when String
      connection.get(:Object, object_key)
    when Array
      connection.multi_get(:Object, object_key).values
    end
  end

  def create_subscription(timeline_key, subscriber_key)
    # FIXME: subscriber => '' column is kinda janky
    connection.insert(:Subscription, timeline_key, {subscriber_key => ''})
  end

  def remove_subscription(timeline_key, subscriber_key)
    connection.remove(:Subscription, timeline_key, subscriber_key)
  end

  def subscribers_for(timeline_key)
    connection.get(:Subscription, timeline_key).keys
  end

  def create_event(event_key, data)
    connection.insert(:Event, event_key, data)
  end

  def remove_event(event_key)
    connection.remove(:Event, event_key)
  end

  def event_for(event_key)
    case event_key
    when Array
      connection.multi_get(:Event, event_key).values
    when String
      connection.get(:Event, event_key)
    end
  end

  def create_timeline_event(timeline, event_key)
    uuid = new_guid
    connection.insert(:Timeline, timeline, {uuid => event_key})
    uuid
  end

  def remove_timeline_event(timeline, event_key)
    connection.remove(:Timeline, timeline, event_key)
  end

  def timeline_events_for(timeline)
    connection.get(:Timeline, timeline).values
  end

  def new_guid
    SimpleUUID::UUID.new.to_guid
  end

end

