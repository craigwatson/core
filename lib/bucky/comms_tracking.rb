module Bucky
  class CommsTracking
    
    def self.instance
      @instance ||= CommsTracking.new
    end

    def create_user(attrs, env = nil)
      return if skip? env
      
      ::Intercom::User.create(attrs)

    rescue ::Intercom::AuthenticationError,
            ::Intercom::ServerError,
            ::Intercom::ServiceUnavailableError,
            ::Intercom::ResourceNotFound => e
      report(e)
    end

    def update_tags(attrs, env = nil)
      return if skip? env

      attrs[:tag_list].each do |name|
        add_user_to_tag(attrs[:id], name)
      end
    rescue Bucky::NonFatalException => e
      report(e)
    end
  
    def track(id, action_name, occurred_at = Time.current, env = nil)
      return if skip? env

      user = ::Intercom::User.find_by_user_id(id)
      user.custom_data["#{action_name}_at"] = occurred_at
      user.save

    rescue ::Intercom::AuthenticationError,
            ::Intercom::ServerError,
            ::Intercom::ServiceUnavailableError,
            ::Intercom::ResourceNotFound => e
      report(e)
    end

    def skip?(env, expected_env = 'production')
      env != expected_env
    end

    private

    def add_user_to_tag(id, name)
      tag = find_or_create_tag(name)
      tag.user_ids = [id.to_s]
      tag.color = 'blue'
      tag.tag_or_untag = 'tag'
      tag.save
    end

    def find_or_create_tag(name)
      tag = find_tag_by_name(name)
      tag.present? ? tag : new_tag(name)
    end

    def find_tag_by_name(name)
      ::Intercom::Tag.find_by_name name
    rescue Intercom::ResourceNotFound
      return nil
    rescue ::Intercom::AuthenticationError,
            ::Intercom::ServerError,
            ::Intercom::ServiceUnavailableError => e
      raise Bucky::NonFatalException.new(e)
    end

    def new_tag(name=nil)
      tag = ::Intercom::Tag.new
      tag.name = name unless name.nil?
      tag
    rescue ::Intercom::AuthenticationError,
            ::Intercom::ServerError,
            ::Intercom::ServiceUnavailableError,
            ::Intercom::ResourceNotFound => e
      raise Bucky::NonFatalException.new(e)
    end

    def report(exception)
      if Object.const_defined?('Rails')
        Rails.logger.warn(exception.message)
        Rails.logger.warn(exception.backtrace.join("\n"))
      end

      Airbrake.notify(exception) if Object.const_defined?('Airbrake')
      nil
    end
  end
end