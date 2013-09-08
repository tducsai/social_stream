module SocialStream
  module Search
    #TODO: sync with ThinkingSphinx min_infix_len and min_prefix_len options
    MIN_QUERY = 3

    class << self
      def keys(search_type)
        case search_type
        when :quick
          SocialStream.quick_search_models
        when :extended
          extended_search_models.keys
        end
      end

      def options_for_type_select
        keys(:extended).map{ |k|
          [ I18n.t("#{ k }", count: :other), k ]
        }.unshift([ I18n.t("search.show_all"), "" ])
      end

      def models(search_type, key = nil)
        case search_type
        when :quick
          quick_search_models
        when :extended
          if key.present?
            if extended_search_models.keys.include?(key.to_sym)
              extended_search_models[key.to_sym]
            else
              if extended_search_models.values.flatten.map{ |k| k.to_s }.include?(key.to_s.classify)
                [key.to_s.classify.constantize]
              else
                raise "Unknown search key #{ key }"
              end
            end
          else
            extended_search_models.values.flatten
          end
        when :repository
          SocialStream.repository_models.map{ |m| m.to_s.classify.constantize }
        else
          raise "Unknown search type #{ search_type }"
        end
      end

      def search(query, subject, options = {})
        ThinkingSphinx.search *args_for_search(query, subject, options)
      end

      def count(query, subject, options = {})
        ThinkingSphinx.count *args_for_search(query, subject, options)
      end

      private

      def quick_search_models
        @quick_search_models ||=
          parse_quick_search_models
      end

      def parse_quick_search_models
        SocialStream.quick_search_models.map{ |m|
          m.to_s.classify.constantize
        }
      end

      def extended_search_models
        @extended_search_models ||=
          parse_extended_search_models 
      end

      # Get a normalized hash from the configuration. Converts this:
      #
      #   [ :excursion, :user, { :resource => [ :post, :comment, :picture ] }
      #
      # into this:
      #
      #   {
      #     :excursion => [ Excursion ],
      #     :user => [ User ],
      #     :resource => [ Post, Comment, Picture ]
      #   }
      #
      def parse_extended_search_models
        SocialStream.extended_search_models.inject({}) do |hash, entry|
          case entry
          when Hash
            hash.update entry.inject({}){ |h, e|
              h[e.first] = Array.wrap(e.last).map{ |f| f.to_s.classify.constantize }
              h
            }
          when Symbol
            hash[entry] = Array.wrap(entry.to_s.classify.constantize)
          else
            raise "Unknown entry in config.extended_search_models #{ entry }"
          end

          hash
        end
      end

      def args_for_search(query, subject, options = {})
        options[:mode] ||= :extended

        models = models(options[:mode], options[:key])

        with = {}

        if options[:owner].present?
          with[:owner_id] = Actor.normalize_id(options[:owner])
        end

        if subject != options[:owner] || options[:owner].blank?
          with[:relation_ids] = Relation.ids_shared_with(subject)
        end

        [
          query,
          classes: models,
          with: with,
          limit: options[:limit],
          page: options[:page]
        ]
      end
    end
  end
end
