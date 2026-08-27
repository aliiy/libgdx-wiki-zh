---
title: Box2D
---
# 在 libGDX 中设置 Box2D

Box2D 是一个二维物理库，是最流行的 2D 游戏物理库之一，已被移植到许多语言和不同引擎中，包括 libGDX。libGDX 中的 Box2D 实现是 C++ 引擎外的一层轻量 Java 封装，因此其[文档](https://box2d.org/documentation/)可能会很有帮助。

Box2D 是一个扩展，默认不包含在 libGDX 中，因此需要手动安装。

## 目录

  * [初始化](/wiki/extensions/physics/box2d#initialization)
  * [创建世界](/wiki/extensions/physics/box2d#creating-a-world)
  * [调试渲染器](/wiki/extensions/physics/box2d#debug-renderer)
  * [推进模拟](/wiki/extensions/physics/box2d#stepping-the-simulation)
  * [渲染](/wiki/extensions/physics/box2d#rendering)
  * [对象/刚体](/wiki/extensions/physics/box2d#objectsbodies)
    * [动态刚体](/wiki/extensions/physics/box2d#dynamic-bodies)
    * [静态刚体](/wiki/extensions/physics/box2d#static-bodies)
    * [运动刚体](/wiki/extensions/physics/box2d#kinematic-bodies)
  * [冲量/力](/wiki/extensions/physics/box2d#impulsesforces)
  * [关节和齿轮](/wiki/extensions/physics/box2d#joints-and-gears)
  * [Fixture 形状](/wiki/extensions/physics/box2d#fixture-shapes)
  * [精灵和刚体](/wiki/extensions/physics/box2d#sprites-and-bodies)
  * [传感器](/wiki/extensions/physics/box2d#sensors)
  * [接触监听器](/wiki/extensions/physics/box2d#contact-listeners)
  * [资源](/wiki/extensions/physics/box2d#resources)
  * [工具](/wiki/extensions/physics/box2d#tools)

## 初始化

要初始化 Box2D，必须调用 `Box2D.init()`。为保持向后兼容，首次创建 `World` 也会产生相同效果，但应优先使用 `Box2D` 类。

## 创建世界

设置 Box2D 时首先需要一个世界。世界对象保存所有物理对象/刚体，并模拟它们之间的反应。但它不会替你渲染对象，这需要使用 libGDX 图形函数。不过，libGDX 提供了 Box2D 调试渲染器，非常适合调试物理模拟，甚至可以在编写渲染代码前测试游戏玩法。

可以使用以下代码创建世界：

```java
World world = new World(new Vector2(0, -10), true);
```

第一个参数是包含重力的二维向量：0 表示水平方向没有重力，-10 表示类似现实中的向下作用力（假设 y 轴向上）。这些值可以自行设置，但请保持比例恒定。在 Box2D 中，1 个单位 = 1 米。

创建世界时的第二个值是布尔值，用于告诉世界是否允许对象休眠。通常应允许对象休眠以节省 CPU，但某些情况下可能不希望对象休眠。

建议使用与 Box2D 相同的比例绘制图形，也就是使用米作为 Sprite 的宽高单位。为了放大图形使其可见，应使用 viewportWidth / viewportHeight 同样以米为单位的相机。例如，绘制宽度为 2.0f（2 米）的 Sprite，并使用 viewportWidth 为 20.0f 的相机时，Sprite 将占窗口宽度的十分之一。

**一个常见错误**是用像素而不是米度量世界。Box2D 对象的移动速度有限。如果使用像素（如 640×480）而不是米（如 12×9），无论怎么做对象都会移动得很慢。

## 调试渲染器

接下来设置调试渲染器。通常不会在发布版本的游戏中使用它，但为了测试，可以这样设置：

```java
Box2DDebugRenderer debugRenderer = new Box2DDebugRenderer();
```



## 推进模拟

要更新模拟，需要让世界推进。推进本质上是随时间更新世界对象。调用推进函数的最佳位置是在 `render()` 循环末尾。在理想情况下，每个人的帧率都相同。

```java
world.step(1/60f, 6, 2);
```

第一个参数是时间步长，即希望世界模拟的时间长度。大多数情况下应使用固定时间步长。libGDX 建议使用 `1/60f`（1/60 秒）到 `1/240f`（1/240 秒）之间的值。

另外两个参数是 `velocityIterations` 和 `positionIterations`。现在将它们设为 `6` 和 `2`，详情可参阅 Box2D 文档。

模拟推进本身就是一个独立主题。关于可变时间步长的使用，请参阅[这篇文章](https://gafferongames.com/post/fix_your_timestep/)。

结果可能类似这样：

```java
private float accumulator = 0;

private void doPhysicsStep(float deltaTime) {
    // fixed time step
    // max frame time to avoid spiral of death (on slow devices)
    float frameTime = Math.min(deltaTime, 0.25f);
    accumulator += frameTime;
    while (accumulator >= Constants.TIME_STEP) {
        WorldManager.world.step(Constants.TIME_STEP, Constants.VELOCITY_ITERATIONS, Constants.POSITION_ITERATIONS);
        accumulator -= Constants.TIME_STEP;
    }
}
```

## 渲染

建议在物理推进前渲染所有图形，否则会不同步。使用调试渲染器时可以这样做：

```java
debugRenderer.render(world, camera.combined);
```

第一个参数是 Box2D 世界，第二个参数是 libGDX 相机。



## 对象/刚体

现在运行游戏仍然很无聊，因为没有任何事情发生。世界在推进，但由于没有可交互的对象，我们什么也看不到。接下来添加一些对象。

在 Box2D 中，对象称为 _body_，每个 body 由一个或多个 _fixture_ 组成，fixture 在 body 中具有固定的位置和方向。fixture 可以是任意想象中的形状，也可以组合不同形状的 fixture 来构成所需形状。

fixture 包含形状、密度、摩擦力和恢复系数。形状不言自明。密度是每平方米的质量：保龄球密度很高，而主要充满空气的气球密度很低。摩擦力是对象摩擦或滑过某物时受到的阻力：冰块的摩擦力很低，而橡皮球的摩擦力很高。恢复系数表示弹性：岩石的恢复系数很低，而篮球的恢复系数相当高。恢复系数为 0 的 body 撞到地面后会立即停止，而恢复系数为 1 的 body 会永远弹到相同高度。

Body 有三种类型：dynamic、kinematic 和 static。下面分别介绍。


### 动态刚体

动态刚体会移动，并受到力以及其他动态、运动和静态对象的影响。任何需要移动并受力影响的对象都适合使用动态刚体。

现在已经了解了组成 body 的 fixture，接下来创建一些 body 并为其添加 fixture！

```java
// First we create a body definition
BodyDef bodyDef = new BodyDef();
// We set our body to dynamic, for something like ground which doesn't move we would set it to StaticBody
bodyDef.type = BodyType.DynamicBody;
// Set our body's starting position in the world
bodyDef.position.set(5, 10);

// Create our body in the world using our body definition
Body body = world.createBody(bodyDef);

// Create a circle shape and set its radius to 6
CircleShape circle = new CircleShape();
circle.setRadius(6f);

// Create a fixture definition to apply our shape to
FixtureDef fixtureDef = new FixtureDef();
fixtureDef.shape = circle;
fixtureDef.density = 0.5f;
fixtureDef.friction = 0.4f;
fixtureDef.restitution = 0.6f; // Make it bounce a little bit

// Create our fixture and attach it to the body
Fixture fixture = body.createFixture(fixtureDef);

// Remember to dispose of any shapes after you're done with them!
// BodyDef and FixtureDef don't need disposing, but shapes do.
circle.dispose();
```

现在创建了一个球状对象并将其加入世界。运行游戏应该能看到球落下，但仍然比较无聊，因为它没有可交互的对象。接下来创建一个让球弹跳的地面。



### 静态刚体

静态刚体不会移动，也不受力影响。动态刚体会受到静态刚体影响。静态刚体非常适合地面、墙壁及任何不需要移动的对象，而且需要的计算资源更少。

现在将地面创建为静态刚体，过程与前面创建动态刚体很相似。

```java
// Create our body definition
BodyDef groundBodyDef = new BodyDef();  
// Set its world position
groundBodyDef.position.set(new Vector2(0, 10));  

// Create a body from the definition and add it to the world
Body groundBody = world.createBody(groundBodyDef);  

// Create a polygon shape
PolygonShape groundBox = new PolygonShape();  
// Set the polygon shape as a box which is twice the size of our view port and 20 high
// (setAsBox takes half-width and half-height as arguments)
groundBox.setAsBox(camera.viewportWidth, 10.0f);
// Create a fixture from our polygon shape and add it to our ground body  
groundBody.createFixture(groundBox, 0.0f);
// Clean up after ourselves
groundBox.dispose();
```

注意，我们无需定义 `FixtureDef` 就创建了 fixture。如果只需指定形状和密度，`createFixture` 方法提供了方便的重载。

现在运行游戏，应该能看到球落下并在新建的地面上弹起。尝试修改球的密度和恢复系数等值，观察会发生什么。



### 运动刚体

运动刚体介于静态和动态刚体之间。它像静态刚体一样不对力作出反应，但像动态刚体一样可以移动。运动刚体适合由程序员完全控制运动的对象，例如平台游戏中的移动平台。

可以直接设置运动刚体的位置，但通常更好的做法是设置速度，让 Box2D 负责更新位置。

创建运动刚体的方式与上面的动态和静态刚体基本相同。创建后可以这样控制速度：

```java
// Move upwards at a rate of 1 meter per second
kinematicBody.setLinearVelocity(0.0f, 1.0f);
```

## 冲量/力

除重力和碰撞外，还可以使用冲量和力移动 body。

力会随时间逐渐改变 body 的速度。例如火箭升空时，随着火箭逐渐加速，作用力也会逐步施加。

冲量则会立即改变 body 的速度。例如在吃豆人游戏中，角色始终以恒定速度移动，并在开始移动时立即达到该速度。

首先需要一个用于施加力/冲量的动态刚体，请参阅上面的[动态刚体](#dynamic_bodies)部分。

**施加力**

力以牛顿为单位施加在世界坐标点上。如果力没有施加在质心，会产生扭矩并影响角速度。

```java
// Apply a force of 1 meter per second on the X-axis at pos.x/pos.y of the body slowly moving it right
dynamicBody.applyForce(1.0f, 0.0f, pos.x, pos.y, true);

// If we always want to apply force at the center of the body, use the following
dynamicBody.applyForceToCenter(1.0f, 0.0f, true);
```

**施加冲量**

冲量与力类似，但会立即修改 body 的速度。同样，如果冲量没有施加在 body 中心，就会产生改变角速度的扭矩。冲量的单位是牛顿秒或 kg-m/s。

```java
// Immediately set the X-velocity to 1 meter per second causing the body to move right quickly
dynamicBody.applyLinearImpulse(1.0f, 0, pos.x, pos.y, true);
```

请注意，施加力或冲量会唤醒 body。有时这不是期望的行为，例如施加持续的力时，可能希望允许 body 休眠以提高性能。这时可以将 wake 布尔值设为 false。

```java
// Apply impulse but don't wake the body
dynamicBody.applyLinearImpulse(0.8f, 0, pos.x, pos.y, false);
```

**玩家移动示例**

在这个示例中，我们将让玩家像刺猬索尼克一样向左或向右奔跑，并加速到最大速度。示例中已经创建了一个名为 'player' 的 Dynamic Body。此外，我们还定义了 MAX_VELOCITY 变量，使玩家不会加速超过该值。现在只需在按下按键时施加线性冲量即可。

```java
Vector2 vel = this.player.body.getLinearVelocity();
Vector2 pos = this.player.body.getPosition();

// apply left impulse, but only if max velocity is not reached yet
if (Gdx.input.isKeyPressed(Keys.A) && vel.x > -MAX_VELOCITY) {			
     this.player.body.applyLinearImpulse(-0.80f, 0, pos.x, pos.y, true);
}

// apply right impulse, but only if max velocity is not reached yet
if (Gdx.input.isKeyPressed(Keys.D) && vel.x < MAX_VELOCITY) {
     this.player.body.applyLinearImpulse(0.80f, 0, pos.x, pos.y, true);
}
```

## 关节和齿轮

使用 Box2D 世界创建 joint 前，必须先设置其定义。使用 *initialize* 有助于确保所有 joint 参数都已设置。

注意，在 body 之后销毁 joint 会导致崩溃。销毁 body 也会销毁与其连接的 joint。

```java
DistanceJointDef defJoint = new DistanceJointDef ();
defJoint.length = 0;
defJoint.initialize(bodyA, bodyB, new Vector2(0,0), new Vector2(128, 0));

DistanceJoint joint = (DistanceJoint) world.createJoint(defJoints); // Returns subclass Joint.
```

### DistanceJoint

Distance joint 会使两个 body 之间的距离保持不变。

Distance joint 定义需要指定两个 body 上的锚点，以及非零的 joint 长度。

该定义使用局部锚点，因此初始配置可以稍微违反约束。这有助于保存和加载游戏。

**不要使用零长度或过短的长度！**

```java
// DistanceJointDef.initialize (Body bodyA, Body bodyB, Vector2 anchorA, Vector2 anchorB)

DistanceJointDef defJoint = new DistanceJointDef ();
defJoint.length = 0;
defJoint.initialize(bodyA, bodyB, new Vector2(0,0), new Vector2(128, 0));
```

### FrictionJoint

Friction joint 用于俯视游戏中的摩擦效果。它提供二维平移摩擦和角摩擦。

```java
FrictionJointDef jointDef = new FrictionJointDef ();
jointDef.maxForce = 1f;
jointDef.maxTorque = 1f;
jointDef.initialize(bodyA, bodyB, anchor);
```

### GearJoint

Gear joint 用于连接两个 joint。每个 joint 都可以是 revolute joint 或 prismatic joint。你可以指定齿轮比来绑定两者的运动：coordinate1 + ratio * coordinate2 = constant。齿轮比可以为正也可以为负。如果一个 joint 是 revolute joint，另一个是 prismatic joint，那么齿轮比的单位将是长度或 1/长度。

```java
GearJointDef jointDef = new GearJointDef (); // has no initialize
```

### MotorJoint
Motor joint 用于控制两个 body 之间的相对运动。典型用法是控制动态 body 相对于地面的运动。

```java
MotorJointDef jointDef = new MotorJointDef ();
jointDef.angularOffset = 0f;
jointDef.collideConnected = false;
jointDef.correctionFactor = 0f;
jointDef.maxForce = 1f;
jointDef.maxTorque = 1f;
jointDef.initialize(bodyA, bodyB);
```

### MouseJoint
Mouse joint 用于在测试平台中通过鼠标操作 body。它会尝试将 body 上的某个点移动到光标当前位置。旋转不受限制。

```java
MouseJointDef jointDef = new MouseJointDef();
jointDef.target = new Vector2(Gdx.input.getX(), Gdx.input.getY());

MouseJoint joint = (MouseJoint) world.createJoint(jointDef);
joint.setTarget(new Vector2(Gdx.input.getX(), Gdx.input.getY()));
```

### PrismaticJoint

Prismatic joint 允许两个 body 沿指定轴相对平移，同时阻止相对旋转。因此，Prismatic joint 只有一个自由度。

```java
PrismaticJointDef jointDef = new PrismaticJointDef ();
jointDef.lowerTranslation = -5.0f;
jointDef.upperTranslation = 2.5f;

jointDef.enableLimit = true;
jointDef.enableMotor = true;

jointDef.maxMotorForce = 1.0f;
jointDef.motorSpeed = 0.0f;
```

### PulleyJoint

Pulley 用于创建理想化滑轮。滑轮将两个 body 分别连接到地面以及彼此。当一个 body 上升时，另一个会下降。根据初始配置，滑轮绳的总长度保持不变。

```java
JointDef jointDef = new JointDef ();
float ratio = 1.0f;
jointDef.Initialize(myBody1, myBody2, groundAnchor1, groundAnchor2, anchor1, anchor2, ratio);
```

### RevoluteJoint

Revolute joint 强制两个 body 共享一个锚点，通常称为铰链点。Revolute joint 只有一个自由度：两个 body 的相对旋转，这称为 joint angle。

```java
RevoluteJointDef jointDef = new RevoluteJoint();
jointDef.initialize(bodyA, bodyB, new Vector2(0,0), new Vector2(128, 0));

jointDef.lowerAngle = -0.5f * b2_pi; // -90 degrees
jointDef.upperAngle = 0.25f * b2_pi; // 45 degrees

jointDef.enableLimit = true;
jointDef.enableMotor = true;

jointDef.maxMotorTorque = 10.0f;
jointDef.motorSpeed = 0.0f;
```

### RopeJoint

Rope joint 强制两个 body 上的两个点之间保持最大距离，除此之外没有其他作用。警告：如果尝试在模拟过程中修改最大长度，会出现不符合物理规律的行为。允许动态修改长度的模型会有一定弹性，因此这里没有采用这种实现。如果需要动态控制长度，请参阅 b2DistanceJoint。

```java
RopeJointDef jointDef = new RopeJointDef (); // has no initialize
```

### WeldJoint

Weld joint 本质上会将两个 body 粘在一起。由于 island 约束求解器是近似的，Weld joint 可能会有些变形。

```java
WeldJointDef jointDef = new WeldJointDef ();
jointDef.initialize(bodyA, bodyB, anchor);
```

### WheelJoint

Wheel joint 提供两个自由度：沿 bodyA 中固定轴的平移，以及平面内的旋转。可以使用 joint limit 限制运动范围，并使用 joint motor 驱动旋转或模拟旋转摩擦。该 joint 专为车辆悬挂设计。

```java
WheelJointDef jointDef = new WheelJointDef();
jointDef.maxMotorTorque = 1f;
jointDef.motorSpeed = 0f;
jointDef.dampingRatio = 1f;
jointDef.initialize(bodyA, bodyB, anchor, axis); // axis is Vector2(1,1)

WheelJoint joint = (WheelJoint) physics.createJoint(jointDef);
joint.setMotorSpeed(1f);
```

## Fixture 形状

如前所述，fixture 包含形状、密度、摩擦力和恢复系数。
开箱即用即可轻松创建方形（如[静态刚体](/wiki/extensions/physics/box2d#static-bodies)一节所示）和圆形（如[动态刚体](/wiki/extensions/physics/box2d#dynamic-bodies)一节所示）。

可以使用以下类以编程方式定义更复杂的形状：
* ChainShape,
* EdgeShape,
* PolygonShape

不过，使用第三方工具可以直接定义形状并将其导入游戏。

### 使用 box2d-editor 导入复杂形状

[box2d-editor](https://github.com/julienvillegas/box2d-editor) 是一个免费的开源工具，可用于定义复杂形状并将其加载到游戏中。
使用 box2d-editor 将形状导入游戏的示例可在 [Libgdx.info](https://libgdxinfo.wordpress.com/box2d-importing-complex-bodies/) 找到。

更多工具请查看[工具](/wiki/extensions/physics/box2d#Tools)一节。

简而言之，如果使用 Box2d-editor：
* 在 Box2d-editor 中创建形状。
* 导出场景，并将文件复制到资源文件夹。
* 将 BodyEditorLoader.java 文件复制到 "core" 模块的源代码文件夹。

然后可以在游戏中这样使用：

```java
BodyEditorLoader loader = new BodyEditorLoader(Gdx.files.internal("box2d_scene.json"));

BodyDef bd = new BodyDef();
bd.type = BodyDef.BodyType.KinematicBody;
body = world.createBody(bd);

// 2. Create a FixtureDef, as usual.
FixtureDef fd = new FixtureDef();
fd.density = 1;
fd.friction = 0.5f;
fd.restitution = 0.3f;

// 3. Create a Body, as usual.
loader.attachFixture(body, "gear", fd, scale);
```

## 精灵和刚体

管理精灵或游戏对象与 Box2D 之间关联的最简单方法是使用 Box2D 的 User Data。你可以将用户数据设置为游戏对象，然后根据 Box2D body 更新对象的位置。

设置 body 的用户数据很简单：

```java
body.setUserData(Object);
```

它可以设置为任意 Java 对象。也可以创建自己的游戏 actor/object 类，以便在其中保存对物理 body 的引用。

Fixture 也可以用相同方式设置用户数据。

```java
fixture.setUserData(Object);
```

要更新所有 actor/sprite，可以在游戏的渲染循环中遍历世界中的所有 body。

```java
// Create an array to be filled with the bodies
// (better don't create a new one every time though)
Array<Body> bodies = new Array<Body>();
// Now fill the array with all bodies
world.getBodies(bodies);

for (Body b : bodies) {
    // Get the body's user data - in this example, our user
    // data is an instance of the Entity class
    Entity e = (Entity) b.getUserData();

    if (e != null) {
        // Update the entities/sprites position and angle
        e.setPosition(b.getPosition().x, b.getPosition().y);
        // We need to convert our angle from radians to degrees
        e.setRotation(MathUtils.radiansToDegrees * b.getAngle());
    }
}
```

然后像往常一样使用 libGDX `SpriteBatch` 渲染精灵。

## 传感器
传感器是碰撞时不会产生自动响应（例如施加力）的 Body。当需要完全控制两个形状碰撞时发生的事情时，这很有用。
例如，考虑一个具有圆形视野范围的无人机。这个 body 应跟随无人机，但不应对无人机或其他 body 产生物理反应，只需检测目标是否进入其形状范围。

要将 body 配置为传感器，请将 `isSensor` 标志设为 true。例如：

```java
//At the definition of the Fixture
fixtureDef.isSensor = true;
```

要监听传感器接触，需要实现 ContactListener 接口方法。

## 接触监听器
ContactListener 会监听特定 fixture 上的碰撞事件。方法会接收 Contact 对象，其中包含参与碰撞的两个 body 的信息。
对象与另一个对象重叠时会调用 beginContact 方法；对象不再碰撞时会调用 endContact 方法。

```java
public class ListenerClass implements ContactListener {
		@Override
		public void endContact(Contact contact) {

		}

		@Override
		public void beginContact(Contact contact) {

		}
	};
```

需要在 screen 的 show() 或 init() 方法中将此类设置为世界的 contact listener。

```java
world.setContactListener(ListenerClass);
```

可以从 contact 的 fixture 中获取 body 的信息。
根据应用设计，可以将 Entity 类的实例放入 Body 或 Fixture 的用户数据中，这样就能从 Contact 中使用它并进行修改（例如改变玩家生命值）。

## 资源

网上有许多优秀的 Box2D 资源，其中大部分代码都可以轻松转换为 libGDX 代码。

  * [LibGDX.info](https://libgdxinfo.wordpress.com/box2d-basic/) 还提供了 Box2D 与 Scene2D 的基础实现和代码示例。
  * [Box2D 文档](https://box2d.org/documentation/)和 [Discord](https://discord.com/invite/NKYgCBP) 都是寻求帮助的好去处。
  * 一套非常优秀的 [Box2D 教程](https://www.iforce2d.net/b2dtut/)，涵盖了许多不同问题，而你在开发游戏时很可能会遇到这些问题。

## 工具

以下是可与 Box2D 和 libGDX 配合使用的工具列表：

### 免费开源

  * [Physics Body Editor](https://github.com/julienvillegas/box2d-editor)

代码示例见 [https://libgdxinfo.wordpress.com](https://libgdxinfo.wordpress.com/box2d-importing-complex-bodies//)

### 商业工具

  * [RUBE](https://www.iforce2d.net/rube/) 编辑器可用于创建 Box2D 世界。使用 [RubeLoader](https://github.com/indiumindeed/RubeLoader) 将 RUBE 数据加载到 libGDX 中。
  * [PhysicsEditor](https://www.codeandweb.com/physicseditor)
