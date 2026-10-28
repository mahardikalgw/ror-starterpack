class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    render inertia: "home", props: {
      marketing: MarketingContent.payload(signed_in: authenticated?),
      meta: { page_title: "Nexus · Analytics starter template" }
    }
  end
end
