resource "aws_dynamodb_table" "users_table" {
    name = "${var.environment}_pca_users"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "userId"

    attribute {
      name = "userId"
      type = "S" # String
    }

    tags = {
        Name = "${var.environment}_pca_users"
    }
}

resource "aws_dynamodb_table" "conversations_table" {
    name = "${var.environment}_pca_conversations"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "userId"
    range_key = "conversationId"

    attribute {
        name = "userId"
        type = "S"
    }

    attribute {
        name = "conversationId"
        type = "S"
    }

    attribute {
        name = "lastUpdated"
        type = "N" # Number
    }

    global_secondary_index {
        name = "UserConversationsByTime"
        hash_key = "userId"
        range_key = "lastUpdated"
        projection_type = "ALL"
    }

    tags = {
        name = "${var.environment}_pca_conversations"
    }

    ttl {
        attribute_name = "expiresAt"
        enabled = true
    }
}

resource "aws_dynamodb_table" "messages_table" {
    name = "${var.environment}_pca_messages"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "conversationId"
    range_key = "timestamp"

    attribute {
        name = "conversationId"
        type = "S"
    }

    attribute {
        name = "timestamp"
        type = "N"
    }

    attribute {
        name = "userId"
        type = "S"
    }

    global_secondary_index {
      name = "UserMessages"
      hash_key = "userId"
      range_key = "timestamp"
      projection_type = "ALL"
    }

    # TTL for message expiration
    ttl {
        attribute_name = "expiresAt"
        enabled        = true
    }

    tags = {
        name = "${var.environment}_pca_messages"
    }
}