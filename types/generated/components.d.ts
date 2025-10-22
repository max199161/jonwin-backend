import type { Schema, Struct } from '@strapi/strapi';

export interface ContactContactInfo extends Struct.ComponentSchema {
  collectionName: 'components_contact_contact_infos';
  info: {
    description: '';
    displayName: 'Contact Info';
  };
  attributes: {
    address: Schema.Attribute.Text;
    email: Schema.Attribute.Email;
    phone: Schema.Attribute.String;
  };
}

export interface ContactFormSettings extends Struct.ComponentSchema {
  collectionName: 'components_contact_form_settings';
  info: {
    description: '';
    displayName: 'Form Settings';
  };
  attributes: {
    enquiry_types: Schema.Attribute.Enumeration<
      ['General', 'Support', 'Partnership']
    >;
    error_message: Schema.Attribute.Text;
    form_description: Schema.Attribute.Text;
    form_title: Schema.Attribute.String;
    submit_button_text: Schema.Attribute.String;
    success_message: Schema.Attribute.Text;
    title_options: Schema.Attribute.Enumeration<
      ['Mr', 'Ms', 'Mrs', 'Dr', 'Prof']
    >;
  };
}

export interface ContactMapSettings extends Struct.ComponentSchema {
  collectionName: 'components_contact_map_settings';
  info: {
    description: '';
    displayName: 'Map Settings';
  };
  attributes: {
    custom_map_styles: Schema.Attribute.JSON;
    latitude: Schema.Attribute.Decimal;
    longitude: Schema.Attribute.Decimal;
    marker_icon: Schema.Attribute.Media<'images'>;
    zoom_level: Schema.Attribute.Integer;
  };
}

export interface ContactSocialMedia extends Struct.ComponentSchema {
  collectionName: 'components_contact_social_medias';
  info: {
    description: '';
    displayName: 'Social Media';
  };
  attributes: {
    icon: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    is_active: Schema.Attribute.Boolean;
    platform: Schema.Attribute.Enumeration<
      ['wechat', 'twitter', 'xiaohongshu', 'instagram', 'facebook', 'linkedin']
    >;
    qr_code: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    url: Schema.Attribute.String;
    username: Schema.Attribute.String;
  };
}

export interface GlobalCtaButton extends Struct.ComponentSchema {
  collectionName: 'components_global_cta_buttons';
  info: {
    description: '';
    displayName: 'CTA Button';
  };
  attributes: {
    link: Schema.Attribute.String;
    text: Schema.Attribute.String;
  };
}

export interface HomepageBusiness extends Struct.ComponentSchema {
  collectionName: 'components_homepage_businesses';
  info: {
    description: '';
    displayName: 'Business';
  };
  attributes: {
    description: Schema.Attribute.Text;
    image: Schema.Attribute.Media<'images'>;
    learn_more_link: Schema.Attribute.String;
    title: Schema.Attribute.String;
  };
}

export interface HomepageBusinessSection extends Struct.ComponentSchema {
  collectionName: 'components_homepage_business_sections';
  info: {
    description: '';
    displayName: 'Business Section';
  };
  attributes: {
    Business: Schema.Attribute.Component<'homepage.business', true>;
    title: Schema.Attribute.String;
  };
}

export interface HomepageDistributionPointSection
  extends Struct.ComponentSchema {
  collectionName: 'components_homepage_distribution_point_sections';
  info: {
    description: '';
    displayName: 'Distribution Point Section';
  };
  attributes: {
    cta_link: Schema.Attribute.String;
    cta_text: Schema.Attribute.String;
    description: Schema.Attribute.Text;
    highlight_number: Schema.Attribute.String;
    title: Schema.Attribute.String;
  };
}

export interface HomepageEventsSection extends Struct.ComponentSchema {
  collectionName: 'components_homepage_events_sections';
  info: {
    displayName: 'Events Section';
  };
  attributes: {
    events: Schema.Attribute.Relation<'oneToMany', 'api::event.event'>;
  };
}

export interface HomepageHero extends Struct.ComponentSchema {
  collectionName: 'components_homepage_heroes';
  info: {
    description: '';
    displayName: 'Hero Section';
  };
  attributes: {
    Hero_Slide: Schema.Attribute.Component<'homepage.hero-slide', true>;
  };
}

export interface HomepageHeroSlide extends Struct.ComponentSchema {
  collectionName: 'components_homepage_hero_slides';
  info: {
    description: '';
    displayName: 'Hero Slide';
  };
  attributes: {
    cta_link: Schema.Attribute.String;
    cta_text: Schema.Attribute.String;
    image: Schema.Attribute.Media<'images'>;
    mediaType: Schema.Attribute.Enumeration<['image', 'video']> &
      Schema.Attribute.DefaultTo<'image'>;
    subtitle: Schema.Attribute.String;
    title: Schema.Attribute.String;
    video: Schema.Attribute.Media<'videos'>;
  };
}

export interface HomepageLicensePartners extends Struct.ComponentSchema {
  collectionName: 'components_homepage_license_partners';
  info: {
    description: '';
    displayName: 'License Partners';
  };
  attributes: {
    partners: Schema.Attribute.Relation<'oneToMany', 'api::partner.partner'>;
  };
}

export interface HomepageLicensePartnersSection extends Struct.ComponentSchema {
  collectionName: 'components_homepage_license_partners_sections';
  info: {
    description: '';
    displayName: 'License Partners Section';
  };
  attributes: {
    cta_link: Schema.Attribute.String;
    cta_text: Schema.Attribute.String;
    description: Schema.Attribute.Text;
    highlight_number: Schema.Attribute.String;
    left_license_partners: Schema.Attribute.Component<
      'homepage.license-partners',
      false
    >;
    right_license_partners: Schema.Attribute.Component<
      'homepage.license-partners',
      false
    >;
    title: Schema.Attribute.String;
  };
}

export interface HomepageNewsAndPressSection extends Struct.ComponentSchema {
  collectionName: 'components_homepage_news_and_press_sections';
  info: {
    displayName: 'News and Press Section';
  };
  attributes: {
    news_and_presses: Schema.Attribute.Relation<
      'oneToMany',
      'api::news-and-press.news-and-press'
    >;
  };
}

export interface HomepageRetailPointSection extends Struct.ComponentSchema {
  collectionName: 'components_homepage_retail_point_sections';
  info: {
    displayName: 'Retail Point Section';
  };
  attributes: {
    cta_link: Schema.Attribute.String;
    cta_text: Schema.Attribute.String;
    description: Schema.Attribute.Text;
    highlight_number: Schema.Attribute.String;
    image_1: Schema.Attribute.Media<'images'>;
    image_2: Schema.Attribute.Media<'images'>;
    image_3: Schema.Attribute.Media<'images'>;
    title: Schema.Attribute.String;
  };
}

export interface LocalFeatures extends Struct.ComponentSchema {
  collectionName: 'components_local_features';
  info: {
    description: '';
    displayName: 'features';
  };
  attributes: {
    description: Schema.Attribute.Text;
    image: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    title: Schema.Attribute.String;
  };
}

export interface LocalLogisticsItems extends Struct.ComponentSchema {
  collectionName: 'components_local_logistics_items';
  info: {
    description: '';
    displayName: 'logistics Items';
  };
  attributes: {
    description: Schema.Attribute.Text;
    image: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    titile: Schema.Attribute.String;
  };
}

export interface OverseaBenefits extends Struct.ComponentSchema {
  collectionName: 'components_oversea_benefits';
  info: {
    description: '';
    displayName: 'benefits';
  };
  attributes: {
    description: Schema.Attribute.Text;
    title: Schema.Attribute.String;
  };
}

export interface OverviewAwardsSection extends Struct.ComponentSchema {
  collectionName: 'components_overview_awards_sections';
  info: {
    displayName: 'Awards Section';
  };
  attributes: {
    award_name: Schema.Attribute.String;
    title: Schema.Attribute.String;
    year: Schema.Attribute.String;
  };
}

export interface OverviewMilestoneSection extends Struct.ComponentSchema {
  collectionName: 'components_overview_milestone_sections';
  info: {
    description: '';
    displayName: 'Milestone Section';
  };
  attributes: {
    description: Schema.Attribute.Text;
    logo: Schema.Attribute.Media<'images', true>;
    year: Schema.Attribute.String;
  };
}

export interface OverviewWhatWeDoSection extends Struct.ComponentSchema {
  collectionName: 'components_overview_what_we_do_sections';
  info: {
    displayName: 'What We Do Section';
  };
  attributes: {
    description: Schema.Attribute.Text;
    icon: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    title: Schema.Attribute.String;
  };
}

export interface WholesaleSection extends Struct.ComponentSchema {
  collectionName: 'components_wholesale_sections';
  info: {
    description: '';
    displayName: 'Highlight Grid';
  };
  attributes: {
    buttonLabel: Schema.Attribute.String;
    buttonUrl: Schema.Attribute.String;
    description: Schema.Attribute.Blocks;
    openInNewTab: Schema.Attribute.Boolean;
    sequence: Schema.Attribute.String;
    title: Schema.Attribute.String;
  };
}

export interface WholesaleWhyChooseUs extends Struct.ComponentSchema {
  collectionName: 'components_wholesale_why_choose_uses';
  info: {
    displayName: 'Why Choose Us';
  };
  attributes: {
    description: Schema.Attribute.Text;
    title: Schema.Attribute.String;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'contact.contact-info': ContactContactInfo;
      'contact.form-settings': ContactFormSettings;
      'contact.map-settings': ContactMapSettings;
      'contact.social-media': ContactSocialMedia;
      'global.cta-button': GlobalCtaButton;
      'homepage.business': HomepageBusiness;
      'homepage.business-section': HomepageBusinessSection;
      'homepage.distribution-point-section': HomepageDistributionPointSection;
      'homepage.events-section': HomepageEventsSection;
      'homepage.hero': HomepageHero;
      'homepage.hero-slide': HomepageHeroSlide;
      'homepage.license-partners': HomepageLicensePartners;
      'homepage.license-partners-section': HomepageLicensePartnersSection;
      'homepage.news-and-press-section': HomepageNewsAndPressSection;
      'homepage.retail-point-section': HomepageRetailPointSection;
      'local.features': LocalFeatures;
      'local.logistics-items': LocalLogisticsItems;
      'oversea.benefits': OverseaBenefits;
      'overview.awards-section': OverviewAwardsSection;
      'overview.milestone-section': OverviewMilestoneSection;
      'overview.what-we-do-section': OverviewWhatWeDoSection;
      'wholesale.section': WholesaleSection;
      'wholesale.why-choose-us': WholesaleWhyChooseUs;
    }
  }
}
