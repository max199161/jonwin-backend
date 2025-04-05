export default () => ({ slugify: {
    enabled: true,
    config: {
      contentTypes: {
        store: {
          field: 'slug',
          references: 'name',
        },
      },
    },
  },});
