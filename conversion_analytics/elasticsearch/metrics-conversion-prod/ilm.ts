import { IlmPolicy } from "@elastic/elasticsearch/lib/api/types";

export const name = "conversion_data_stream_lifecycle_policy";
export const body = {
  phases: {
    hot: {
      actions: {
        rollover: {
          max_age: "30d",
          max_primary_shard_size: "50gb",
        },
        set_priority: {
          priority: 100,
        },
      },
      min_age: "0ms",
    },
  },
} as IlmPolicy;
