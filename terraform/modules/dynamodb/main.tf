resource "aws_dynamodb_table" "chat_table" {
    name = "${var.environment}_ChatTable"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "userId"
    range_key = "sortKey"

    attribute {
        name = "userId"
        type = "S" # String
    }

    attribute {
        name = "sortKey"
        type = "S" # String
    }

    attribute {
        name = "chatId"
        type = "S" # String
    }

    attribute {
        name = "GSISK"
        type = "S" # String
    }

    # GSI for querying all messages within a specific conversation
    global_secondary_index {
        name               = "ChatMessages"
        hash_key           = "chatId" 
        range_key          = "GSISK"
        projection_type    = "ALL"
    }

    # TTL attribute for optional message expiration
    ttl {
        attribute_name = "expiresAt"
        enabled        = true
    }
    
    tags = {
        environment = var.environment
    }
}