with stats as (

    select *
    from {{ var('ad_stats') }}
), 

accounts as (

    select *
    from {{ var('account_history') }}
    where is_most_recent_record = True
), 

campaigns as (

    select *
    from {{ var('campaign_history') }}
    where is_most_recent_record = True
), 

ad_groups as (

    select *
    from {{ var('ad_group_history') }}
    where is_most_recent_record = True
),

ads as (

    select *
    from {{ var('ad_history') }}
    where is_most_recent_record = True
), 

fields as (

    select
        stats.date_day,
        accounts.account_name,
        accounts.account_id,
        campaigns.campaign_name,
        campaigns.campaign_id,
        ad_groups.ad_group_name,
        ad_groups.ad_group_id,
        ads.ad_id,
        ads.ad_status,
        ads.ad_type,
        ads.display_url,
        ads.source_final_urls,
        sum(stats.spend) as spend,
        sum(stats.clicks) as clicks,
        sum(stats.impressions) as impressions

        {% for metric in var('google_ads__ad_stats_passthrough_metrics', []) %}
        , sum(stats.{{ metric }}) as {{ metric }}
        {% endfor %}

    from stats
    left join ads
        on stats.ad_id = ads.ad_id
        and stats.ad_group_id = ads.ad_group_id
    left join ad_groups
        on ads.ad_group_id = ad_groups.ad_group_id
    left join campaigns
        on ad_groups.campaign_id = campaigns.campaign_id
    left join accounts
        on campaigns.account_id = accounts.account_id
    {{ dbt_utils.group_by(12) }}
)

select *
from fields