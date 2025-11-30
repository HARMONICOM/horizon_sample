-- Seed initial users data for E2E testing
-- Admin user: login_id=admin, password=admin123
-- Test users: login_id=user1/user2/user3/user4, password=test1234

-- Admin user for testing
INSERT INTO users (login_id, password_hash, name, email)
VALUES ('admin', '$argon2id$v=19$m=65536,t=3,p=1$jS20x2PQWyyyyG6fv7wJuQ$mZWG9nO/MA2MoftTb0lOqu0jtqfaU63Fp+LD54CSFrw', 'Admin User', 'admin@example.com');

-- Test users (all with password: test1234)
INSERT INTO users (login_id, password_hash, name, email)
VALUES ('user1', '$argon2id$v=19$m=65536,t=3,p=1$jS20x2PQWyyyyG6fv7wJuQ$mZWG9nO/MA2MoftTb0lOqu0jtqfaU63Fp+LD54CSFrw', 'Test User 1', 'user1@example.com');
INSERT INTO users (login_id, password_hash, name, email)
VALUES ('user2', '$argon2id$v=19$m=65536,t=3,p=1$jS20x2PQWyyyyG6fv7wJuQ$mZWG9nO/MA2MoftTb0lOqu0jtqfaU63Fp+LD54CSFrw', 'Test User 2', 'user2@example.com');
INSERT INTO users (login_id, password_hash, name, email)
VALUES ('user3', '$argon2id$v=19$m=65536,t=3,p=1$jS20x2PQWyyyyG6fv7wJuQ$mZWG9nO/MA2MoftTb0lOqu0jtqfaU63Fp+LD54CSFrw', 'Test User 3', 'user3@example.com');
INSERT INTO users (login_id, password_hash, name, email)
VALUES ('user4', '$argon2id$v=19$m=65536,t=3,p=1$jS20x2PQWyyyyG6fv7wJuQ$mZWG9nO/MA2MoftTb0lOqu0jtqfaU63Fp+LD54CSFrw', 'Test User 4', 'user4@example.com');
