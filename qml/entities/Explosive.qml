import QtQuick 2.9

/*
for (int i = 0; i < numRays; i++) {
      float angle = (i / (float)numRays) * 360 * DEGTORAD;
      b2Vec2 rayDir( sinf(angle), cosf(angle) );

      b2BodyDef bd;
      bd.type = b2_dynamicBody;
      bd.fixedRotation = true; // rotation not necessary
      bd.bullet = true; // prevent tunneling at high speed
      bd.linearDamping = 10; // drag due to moving through air
      bd.gravityScale = 0; // ignore gravity
      bd.position = center; // start at blast center
      bd.linearVelocity = blastPower * rayDir;
      b2Body* body = m_world->CreateBody( &bd );

      b2CircleShape circleShape;
      circleShape.m_radius = 0.05; // very small

      b2FixtureDef fd;
      fd.shape = &circleShape;
      fd.density = 60 / (float)numRays; // very high - shared across all particles
      fd.friction = 0; // friction not necessary
      fd.restitution = 0.99f; // high restitution to reflect off obstacles
      fd.filter.groupIndex = -1; // particles should not collide with each other
      body->CreateFixture( &fd );
  }
  */
Rectangle {
    width: 100
    height: 62
}

